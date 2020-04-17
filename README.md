# banned-functions
Ban (built-in) functions from your Hack projects

# Deprecated

HHAST can do this thing without needing the shell out n times, where n is the amount of functions you ban.
You can use this linter instead:

```HACK
namespace ThisWorksInAnyNamespace\BecauseIImportedAllDependenciesIndividually;

use namespace HH\Lib\{C, Str, Vec};
use type Facebook\HHAST\{ASTLintError, ASTLinter, FunctionCallExpression, NameToken, QualifiedName, Script};
use function Facebook\HHAST\{qualified_name_is_fully_qualified, resolve_function};

final class AlternativeFunctionLinter extends ASTLinter {
    const type TContext = Script;
    const type TNode = FunctionCallExpression;

    const dict<string, string> BAD_FUNCTIONS = dict[
        'array_keys' => self::ARRAY_KEYS,
        'array_map' => self::ARRAY_MAP,
        'array_values' => 'varray() does the same thing, but more efficiently.',
        'count' => 'C\count() is a typesafe count().',
        'strlen' => 'Str\length() is a typesafe strlen().',
    ];

    const string ARRAY_KEYS = <<<'ARRAY_KEYS'
array_keys() returns a varray of the keys of the given array.
If you do not care about the keytype of your KeyedContainer, use Keyset\keys().
If you need a zero-based KeyedContainer, use Vec\keys().
ARRAY_KEYS;
    const string ARRAY_MAP = <<<'ARRAY_MAP'
array_map() retains the keys of the KeyedContainer you provide, when you provide two arguments.
If you provide three or more arguments, the keys are zero-based.
If you wish to preserve keys, use Dict\map().
If you wish to have zero-based keys, use Vec\map().
ARRAY_MAP;

    <<__Override>>
    public function getLintErrorForNode(Script $context, this::TNode $node): ?ASTLintError {
        $name = $node->getReceiver();

        if ($name is NameToken) {
            $string_name = $name->getText();
        } else if ($name is QualifiedName) {
            $string_name = $name->getDescendantsOfType(NameToken::class)
                |> Vec\map($$, $n ==> $n->getText())
                |> Str\join($$, '\\');
            if (qualified_name_is_fully_qualified($name)) {
                $string_name = '\\'.$string_name;
            }
        } else {
            return null;
        }

        // Performance won't suffer from resolving a fully qualified name.
        // This is handled very efficiently in resolve_function().
        $resolved_name = resolve_function($string_name, $context, $node);

        if (C\contains_key(static::BAD_FUNCTIONS, $resolved_name)) {
            return new ASTLintError(
                $this,
                Str\format("Please find a better alternative for '%s()':\n%s", $resolved_name, static::BAD_FUNCTIONS[$resolved_name]),
                $node,
            );
        }

        return null;
    }

}

```

### Just don't use X

How many times have you been bitten by using a function with poor types?

```HACK
$users = generator_of_nullable_users() |> iterator_to_array($$);
foreach($users as $user){
  $user->sendEmail();
}
```

This code typechecks and _"It works on your machine"_, but in production...

```
'BadMethodCallException' with message 'Call to a member function sendEmail() on a non-object (null)'
```

Your team is angry, because now they need to check which users got an email and which didn't.
Then they need to send the emails to the users who didn't get one yet.

If only `iterator_to_array()` wasn't untyped...
Or maybe, just use `vec()` instead for the same effect.
Introducing `lexidor/banned-functions`.
You can now make sure that you are not using functions that you shouldn't.

It is smart enough to not complain about usages in vendor.
You _can_ however also scan vendor if you want.
For an example configuration, see [example-config](https://github.com/lexidor/banned-functions/blob/master/example-config.json).
For a complete and up to date spec of the honored options, see [TMasterConfig](https://github.com/lexidor/banned-functions/blob/master/src/TMasterConfig.hack).
