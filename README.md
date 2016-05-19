# wit-crystal

[Crystal](http://crystal-lang.org/) SDK for [Wit.ai](http://wit.ai).

Supports Wit.ai API version `20160516`.
Runs on Crystal `>= 0.17.2`.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  wit:
    github: spalladino/wit-crystal
```

## Examples

### Understand

A query to the `/message` endpoint can be issued by running:

```bash
crystal examples/understand.cr <access-token> In Buenos Aires
> Extracted entities from 'In Buenos Aires'
>  location=[{"confidence" => 0.957859, "type" => "value", "value" => "Buenos Aires", "suggested" => true}]
```

### Quickstart

The code for the [quickstart weather application](https://wit.ai/docs/quickstart) can be executed by running:

```bash
crystal examples/quickstart.cr <access-token>
```

## Usage

`wit-crystal` provides a `Wit::App` class with the following methods:
* `message` - the Wit [message API](https://wit.ai/docs/http/20160330#get-intent-via-text-link)
* `converse` - the low-level Wit [converse API](https://wit.ai/docs/http/20160330#converse-link)
* `run_actions` - a higher-level method to the Wit converse API
* `interactive` - starts an interactive conversation with your bot

Refer to the examples folder for sample usage.

## TODOs

* Add example on using context for message understanding
* Generate and upload documentation
* Add more specs using webmock or similar tool

## Acknowledgements

* The [Wit.ai](https://github.com/wit-ai/) team for building such an awesome tool
* The developers of the [Ruby SDK](https://github.com/wit-ai/wit-ruby) for Wit.ai, on which this library is heavily inspired

## Contributors

- [spalladino](https://github.com/spalladino) Santiago Palladino - creator, maintainer
