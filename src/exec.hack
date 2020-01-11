namespace Lex\BannedFunctions;

use namespace HH\Lib\{C, Str};

function exec(string $command): vec<string> {
  $output = vec[];
  $return_var = -1;
  \exec($command, inout $output, inout $return_var);
  if ($return_var !== 0) {
    throw new \RuntimeException(Str\format(
      'Command: "%s" did not execute successfully. Return code %d, value: "%s"',
      $command,
      $return_var,
      C\last($output) ?? '<<nothing was returned>>',
    ));
  }
  return vec($output);
}
