## Environment-specific configuration
:local ftpServer    "nas.blastwave.lab"
:local ftpUser      "mikrotik"
:local ftpPassword  "<SFTP_USER_PASS>"
#:local ftpPath      "/files/backups-infra/rb5009/"
:local ftpPath      "/files/backups-infra/crs328/"

:local dstFile      "backup"
:local srcFile $dstFile
:local myVer value=[/system package update get installed-version]
:local id value=[/system identity get value-name=name]
:local date [/system clock get date]

## Construct destination file name
:set dstFile ($dstFile . "-" . $id . "-" . $myVer . "-" . $date)

## Perform the actual backup / export
/system backup save name="$srcFile"
:delay 1s
/export file="$srcFile"

## Upload both files via FTP
:foreach i in=(".backup", ".rsc") do={
  /tool fetch address=$ftpServer src-path=($srcFile . $i) user=$ftpUser mode=sftp password=$ftpPassword dst-path=($ftpPath . $dstFile . $i) upload=yes port=22
}

# Free space on local device after uploading the backups
:delay 2s
/file remove [find name=($srcFile . ".backup")]
/file remove [find name=($srcFile . ".rsc")]

## Log
:log info ("Configuration backup created on router $[/system identity get name].")
