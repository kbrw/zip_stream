# ZipStream

Library to read zip file in a stream.
Zip file binary stream -> stream of {:new_file,name} or uncompressed_bin

Erlang zlib library only allows deflate decompress stream.  But
Erlang zip library does not allow content streaming.

## Usage

For instance if you have a zip with multiple files, you can 
use the stream to do: 

```elixir
File.stream!("myfile.zip", [], 500)
|> ZipStream.unzip
|> Stream.reduce(nil,fn 
  {:new_file,name},_current->name
  binary,file_name->
    #DO SOMTHING WITH the binary chunk of file_name
    file_name
end)
```

An other example: your zip contains only one file, in this case you
can simply do the following to get a standard binary stream of this
on file. (drop the `{:new_file,_}` of the single file)

```elixir
binstream = File.stream!("myfile.zip", [], 500)
|> ZipStream.unzip
|> Stream.drop(1)
```

## Known Limitations

This library does not handle all possible zip files, in particular:
- The zip archive contains uncompressed data or data not compressed
  with the deflate algorithm
- The zip archive contains data with the `data_descriptor` format
- The zip archive is a zip64 to handle files bigger than (2^32 4Go)

## Installation

The package can be installed as:

  1. Add zip_stream to your list of dependencies in `mix.exs`:

        def deps do
          [{:zip_stream, "~> 0.1.0"}]
        end

  2. Ensure zip_stream is started before your application:

        def application do
          [applications: [:zip_stream]]
        end

