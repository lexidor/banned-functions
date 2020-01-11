namespace Lex\BannedFunctions;

use namespace HH\Lib\{C, Str};

function errorf(Str\SprintfFormatString $format, mixed ...$args): nothing {
  $format as string;
  if (!Str\ends_with($format, \PHP_EOL)) {
    $format .= \PHP_EOL;
  }
  \fprintf(\STDERR, $format, ...$args);
  exit(1);
}
