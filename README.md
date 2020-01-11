# banned-functions
Ban (built-in) functions from your Hack projects

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
