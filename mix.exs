defmodule ZipStream.Mixfile do
  use Mix.Project

  def project do
    [app: :zip_stream,
     version: "0.2.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: [
       maintainers: ["Arnaud Wetzel"],
       licenses: ["MIT"],
       links: %{
         "GitHub" => "https://github.com/awetzel/zip_stream"
       }
     ],
     description: """
     Library to read zip file in a stream.
     Zip file binary stream -> stream of {:new_file,name} or uncompressed_bin

     Erlang zlib library only allows deflate decompress stream.  But
     Erlang zip library does not allow content streaming.
     """,
     deps: []]
  end

  def application do
    [applications: []]
  end
end
