namespace Lex\BannedFunctions;

final class JsonTypeError extends \Exception {
  public function __construct(\Exception $previous) {
    parent::__construct(
      'The give json did not match exceptations.',
      0,
      $previous,
    );
  }

}
