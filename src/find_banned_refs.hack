namespace Lex\BannedFunctions;

use type HH\Lib\Ref;
use namespace HH\Lib\{C, Dict, Keyset, Vec};

function find_banned_refs(TMasterConfig $config): dict<string, vec<SourceRef>> {
  $src_path = $config['src_path'] ?? 'src/';
  $vendor_path = $config['vendor_path'] ?? 'vendor/';
  $tests_path = $config['tests_path'] ?? 'tests/';

  $banned_everywhere = keyset($config['global'] ?? keyset[]);
  $banned_in_non_vendor = keyset($config['non_vendor'] ?? keyset[]);
  $banned_in_src = keyset($config['src'] ?? keyset[]);
  $banned_in_tests = keyset($config['tests'] ?? keyset[]);

  $non_scanned_functions = new Ref(Keyset\union(
    $banned_everywhere,
    $banned_in_non_vendor,
    $banned_in_src,
    $banned_in_tests,
  ));

  $find_banned_refs = (Container<string> $names) ==> {
    $names = Vec\filter(
      $names,
      $name ==> C\contains_key($non_scanned_functions->value, $name),
    );
    foreach ($names as $name) {
      unset($non_scanned_functions->value[$name]);
    }
    return Dict\from_keys($names, $name ==> find_refs($name));
  };

  $is_in = (string $path) ==> (SourceRef $ref) ==> $ref->isIn($path);
  $is_not_in = (string $path) ==> (SourceRef $ref) ==> !$ref->isIn($path);

  $clean_up_result = (
    dict<string, vec<SourceRef>> $map_of_ref_vecs,
    (function(SourceRef): bool) $predicate,
  ) ==>
    Dict\map($map_of_ref_vecs, $ref_vec ==> Vec\filter($ref_vec, $predicate))
    |> Dict\filter($$, $refs ==> !C\is_empty($refs));

  $global_errors = $find_banned_refs($banned_everywhere);
  $non_vendor_errors = $find_banned_refs($banned_in_non_vendor)
    |> $clean_up_result($$, $is_not_in($vendor_path));
  $src_errors = $find_banned_refs($banned_in_src)
    |> $clean_up_result($$, $is_in($src_path));
  $tests_errors = $find_banned_refs($banned_in_tests)
    |> $clean_up_result($$, $is_in($tests_path));

  invariant(
    C\is_empty($non_scanned_functions->value),
    'Internal error. Non scanned functions left!',
  );

  return Dict\merge(
    $global_errors,
    $non_vendor_errors,
    $src_errors,
    $tests_errors,
  );
}
