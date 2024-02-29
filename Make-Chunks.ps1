Param
(
    [Parameter(Mandatory=$True,Position=1)][string]$FileToSplit,
    [Parameter(Mandatory=$True,Position=3)][string]$OutPutDirectory,
    [Parameter(Mandatory=$True,Position=2)][string]$ChunkPrefix,
    [Parameter(Mandatory=$True,Position=4)][int64]$ChunkSize
)

<#
.SYNOPSIS
    
    Creates "chunks" from a single large file.
    
.DESCRIPTION
    
    Given a filename, splits the file in to several pieces, with each piece being of the specified size.

.PARAMETER FileToSplit

    Full path and filename for the file to be split up.

.PARAMETER OutPutDirectory

    Full path of location to put the chunks. Must contain the trailing \

.PARAMETER ChunkPrefix

    Used to create the filename of the chunks, this is the file prefix for each chunk.

.PARAMETER ChunkSize

    Size in megabytes of each resultant chunk.  Simply, 100 = 100 MB, 1000 = 1000 MB = 1 GB

.EXAMPLE

    Make-Chunks.ps1 -filetosplit D:\Repo\PowerShell\zipper\zipper_output\MyFile.ZIP -outputdirectory D:\Repo\PowerShell\zipper\zipper_chunks -ChunkPrefix "MyChunks" -ChunkSize 100

    Creates 100 MB chunks from MyFile.ZIP in D:\Repo\PowerShell\Zipper\Zipper_Chunks, each prefixed with MyChunks (MyChunks1, MyChunks2, MyChunks3, etc)

.NOTES


	  Author:         Derek Wirch, fortypoundhead.com
    Start Date:     2018-09-24
    Complete Date:  2018-09-24

#>

function ChunkIt($inFile,  $outPrefix, [Int64] $bufSize,$OutPutDirectory){

  $stream = [System.IO.File]::OpenRead($inFile)
  $chunkNum = 1
  $barr = New-Object byte[] $bufSize

  while( $bytesRead = $stream.Read($barr,0,$bufsize))
  {
    
    write-host "reading source file ..."
    $outFile = "$OutPutDirectory\$outPrefix$chunkNum"
    $ostream = [System.IO.File]::OpenWrite($outFile)
    $ostream.Write($barr,0,$bytesRead);
    $ostream.close();
    echo "wrote $outFile"

    # start get hash of file

    write-host "getting hash"
    $HashTheFile=get-filehash $OutFile
    $TH=$HashTheFile.Hash
    $MyFileHash="$OutPrefix$ChunkNum,$TH"
    $MyFileHash | out-file "$OutputDirectory\manifest.txt" -append
    write-host "hash=$TH"
    write-host "sending to manifest"

    # end get hash of file

    $chunkNum += 1
  }
}

# Convert the given int32 size to bytes
$ChunkSize=$ChunkSize*1MB

# send it
ChunkIt -inFile $FileToSplit -outPrefix $ChunkPrefix -OutPutDirectory $OutPutDirectory -bufSize $ChunkSize
