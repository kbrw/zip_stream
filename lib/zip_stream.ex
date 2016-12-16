defmodule ZipStream do
  defmodule Error do defexception [:message] end

  defp zip(z,:header,<<0x50,0x4b,0x03,0x04,_vers::16,_::4,descriptor?::1,_::11,compression::16-little,_other::8*8,
      binsize::32-little,_ressize::32-little,namelen::16-little,extralen::16-little,
      name::binary-size(namelen),_extra::binary-size(extralen),
      rest::binary>>, acc) do
    if compression != 8, do: raise Error, message: "ZipStream only handle deflate compression, zip file unsupported"
    if descriptor? == 1, do: raise Error, message: "ZipStream does not support zip file with data descriptor"
    if binsize == 0xffffffff, do: raise Error, message: "ZipStream does not support zip64 files yet"
    :zlib.inflateInit(z,-15)
    zip(z,:data,binsize,rest, name, [[{:new_file,name}]|acc])
  end
  defp zip(z,:header,<<0x50,0x4b,0x01,0x02,_::binary>>=_bin,acc), do: {endacc(acc),{z,:nomore_files}}
  defp zip(z,:header,bin,acc), do: {endacc(acc),{z,{:inheader,bin}}}

  defp zip(z,:data,0,rest, _, acc), do: zip(z,:header,rest,acc)
  defp zip(z,:data,remsize,"", data_name, acc), do: {endacc(acc),{z,{:indata,data_name,remsize}}}
  defp zip(z,:data,remsize,bin, data_name, acc) do
    case bin do
      <<content::binary-size(remsize), rest::binary>>-> 
        inflated=:zlib.inflate(z,content); :zlib.inflateEnd(z)
        zip(z,:header,rest,[inflated|acc])
      <<content_part::binary>>->
        {endacc([:zlib.inflate(z,content_part)|acc]),{z,{:indata,data_name,remsize-byte_size(content_part)}}}
    end
  end
  defp endacc(acc), do: (acc |> Enum.reverse |> Stream.concat)

  def unzip(byte_stream) do
    Stream.transform(byte_stream,
      fn->{:zlib.open,{:inheader,""}} end, 
      fn
        _,{z,:nomore_files}-> {:halt,{z,:nomore_files}}
        bin,{z,{:inheader,tail}}-> zip(z,:header,tail<>bin,[])
        bin,{z,{:indata,data_name,remsize}}-> zip(z,:data,remsize,bin,data_name,[])
      end,
      fn {z,_}->:zlib.close(z) end
    )
  end
end
