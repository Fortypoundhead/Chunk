Param
(
    [Parameter(Mandatory=$True,Position=1)][string]$ChunkDirectory,
    [Parameter(Mandatory=$True,Position=2)][string]$ChunkPrefix,
    [Parameter(Mandatory=$True,Position=3)][string]$OutputFile
)

<#
.SYNOPSIS
    
    Joins chunks back together to recreate the original file
    
.DESCRIPTION
    
    Given a directory to look in, the prefix to look for, and the desired output filename, this script joins the chunks.

.PARAMETER ChunkDirectory

    Directory where the chunks to be joined are located

.PARAMETER ChunkPrefix
    
    The prefix that was used to chunk the files to be joined.

.Parameter OutputFile

    Full path and filename of the file to create from the chunks.

.EXAMPLE

    Join-Chunks.ps1 -ChunkDirectory "D:\Repo\PowerShell\zipper\zipper_chunks" -OutputFile "D:\Repo\PowerShell\zipper\zipper_stitched\MyFile.ZIP" -ChunkPrefix "MyChunks"

    Looks for chunks prefixed with "MyChunks" in D:\Repo\PowerShell\zipper\zipper_chunks, combining any found files into a new file called MyFile.ZIP.

.NOTES

  	Author:         Derek Wirch, fortypoundhead.com
    Start Date:     2018-09-24
    Complete Date:  2018-09-24

#>

function unchunk($infilePrefix, $outFile, $ChunkDirectory) {

    $ostream = [System.Io.File]::OpenWrite($outFile)
    $chunkNum = 1
    $infileName = "$ChunkDirectory\$infilePrefix$chunkNum"

    $offset = 0

    while(Test-Path $infileName) {
        $bytes = [System.IO.File]::ReadAllBytes($infileName)
        $ostream.Write($bytes, 0, $bytes.Count)
        Write-Host "read $infileName"
        $chunkNum += 1
        $infileName = "$ChunkDirectory\$infilePrefix$chunkNum"
    }

    $ostream.close();
}

unchunk -ChunkDirectory $ChunkDirectory -outFile $OutputFile -infilePrefix $ChunkPrefix
