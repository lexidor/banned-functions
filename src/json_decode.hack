namespace Lex\BannedFunctions;

use namespace Facebook\TypeAssert;

function json_decode<reify T>(string $json): T {
  $data = \json_decode($json, true, 512, \JSON_FB_HACK_ARRAYS);
  try {
    return TypeAssert\matches<T>($data);
  } catch (\Exception $e) {
    throw new JsonTypeError($e);
  }
}
