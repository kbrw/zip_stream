defmodule ZipStreamTest do
  use ExUnit.Case

  for path<-Path.wildcard("test/examples/*.zip") do
    test "examples zip unzip #{path}" do
      path = unquote(path)
      unzipped = File.stream!(path,[],500)
        |> ZipStream.unzip
        |> Enum.reduce([],fn
          {:new_file,file},acc-> [{file,[]}|acc]
          bin,[{file,ioacc}|acc]->[{file,[ioacc,bin]}|acc]
        end)
        |> Enum.map(fn {file,iodata}->{file,IO.iodata_to_binary(iodata)} end)
        |> Enum.sort

      res_dir = "test/examples/#{path |> Path.basename |> Path.rootname}/"
      unzipped_expected = for path<-Path.wildcard(res_dir<>"*") do
        {String.replace(path,res_dir,""),File.read!(path)}
      end |> Enum.sort

      assert Enum.count(unzipped_expected) == Enum.count(unzipped)

      Enum.zip(unzipped_expected,unzipped) |> Enum.each(fn {{name1,f1},{name2,f2}}->
        assert name1 == name2
        assert f1 == f2
      end)
    end
  end
end
