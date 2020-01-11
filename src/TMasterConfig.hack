namespace Lex\BannedFunctions;

type TMasterConfig = shape(
  // Banned for all code in this repository, including your dependencies
  ?'global' => vec<string>,
  // Banned for all code that does not live in vendor_path
  ?'non_vendor' => vec<string>,
  // Banned for all code that lives in src_path
  ?'src' => vec<string>,
  // Banned for all code that lives in src_path
  ?'tests' => vec<string>,
  // Custom vendor path, defaults to vendor/
  ?'vendor_path' => string,
  // Custom tests path, defaults to tests/
  ?'tests_path' => string,
  // Custom src path, defaults to src/
  ?'src_path' => string,
);
