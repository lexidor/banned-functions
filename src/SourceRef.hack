namespace Lex\BannedFunctions;

use namespace HH\Lib\{Regex, Str};

final class SourceRef {
  public function __construct(
    public string $file,
    public int $line,
    public int $colStart,
    public int $colEnd,
  ) {}

  public function isIn(string $directory): bool {
    return Str\contains($this->file, $directory);
  }

  public function toString(): string {
    return Str\format(
      '%s:%d[%d:%d]',
      $this->file,
      $this->line,
      $this->colStart,
      $this->colEnd,
    );
  }

  public static function parseFromHHClientLine(string $line): this {
    $regex =
      re"/^File \"(?<file>[\/\w.-]+)\", line (?<line>\d+), characters (?<col_start>\d+)-(?<col_end>\d+)/";

    $result = Regex\first_match($line, $regex);

    invariant($result is nonnull, 'Could not parse line: %s', $line);

    list($file, $line, $col_start, $col_end) = tuple(
      $result['file'],
      Str\to_int($result['line']),
      Str\to_int($result['col_start']),
      Str\to_int($result['col_end']),
    );

    invariant(
      $line is nonnull && $col_start is nonnull && $col_end is nonnull,
      'Could not parse line: %s',
      $line,
    );

    return new SourceRef($file, $line, $col_start, $col_end);
  }
}
