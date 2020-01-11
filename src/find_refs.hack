namespace Lex\BannedFunctions;

use namespace HH\Lib\{Regex, Vec};

function find_refs(string $function_name): vec<SourceRef> {
  $regex = re"/^[a-z0-9\\\\][\w\\\\]+$/i";
  invariant(
    Regex\matches($function_name, $regex),
    'Invalid function name %s',
    $function_name,
  );
  $refs = exec('hh_client --find-refs '.$function_name);
  \array_pop(inout $refs);
  return Vec\map($refs, $ref ==> SourceRef::parseFromHHClientLine($ref));
}
