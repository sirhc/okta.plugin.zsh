# AWS Okta (aws-okta) plugin

This plugin provides command line completions for the
[`aws-okta`](https://github.com/segmentio/aws-okta) command.

This plugin provides the following convenience functions.

| Function | Purpose |
| --- | --- |
| `aop <profile>` | Execute `aws-okta env <profile>` and set the token in the current shell |

To use the plugin, add `okta` to the plugins array in your zshrc file:

```zsh
plugins=(... okta)
```
