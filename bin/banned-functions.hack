namespace Lex\BannedFunctions;

use namespace HH\Lib\{C, Dict, Vec};
use namespace HH\Lib\Experimental\{File, OS};

<<__EntryPoint>>
async function main_async(): Awaitable<noreturn> {
  autoload();

  $argv = \HH\global_get('argv') as Container<_> |> vec($$);
  $config_path = ($argv[1] ?? null) as ?string;

  if ($config_path is null) {
    return errorf('Usage: %s config_file', $argv[0] as string);
  }

  try {
    $config_file = File\open_read_only_nd($config_path);
  } catch (OS\NotFoundException $e) {
    return errorf('Could not read config: %s', $config_path);
  }

  try {
    $config = (await $config_file->readAsync())
      |> json_decode<TMasterConfig>($$);
  } catch (JsonTypeError $e) {
    return errorf(
      "%s is not valid.\nFor a spec of this format, see %s.\n\nThis is the raw error from TypeAssert:\n%s",
      $config_path,
      TMasterConfig::class,
      $e->getPrevious()?->getMessage() as nonnull,
    );
  } finally {
    await $config_file->closeAsync();
  }

  $banned_refs = find_banned_refs($config)
    |> Dict\map(
      $$,
      $vec_of_refs ==> Vec\map($vec_of_refs, $ref ==> $ref->toString()),
    );

  if (C\is_empty($banned_refs)) {
    exit(0);
  }

  return errorf(
    "Banned functions are being called:\n%s",
    \json_encode($banned_refs, \JSON_PRETTY_PRINT | \JSON_UNESCAPED_SLASHES),
  );
}

/**
 * @author Fred Emmott in hhvm/hhast
 */
function autoload(): void {
  $root = \realpath(__DIR__.'/..');
  $found_autoloader = false;
  while (true) {
    $autoloader = $root.'/vendor/autoload.hack';
    if (\file_exists($autoloader)) {
      $found_autoloader = true;
      require_once($autoloader);
      \Facebook\AutoloadMap\initialize();
      break;
    }
    if ($root === '') {
      break;
    }
    $parts = \explode('/', $root);
    \array_pop(inout $parts);
    $root = \implode('/', $parts);
  }

  if (!$found_autoloader) {
    \fprintf(\STDERR, "Failed to find autoloader.\n");
    exit(1);
  }
}
