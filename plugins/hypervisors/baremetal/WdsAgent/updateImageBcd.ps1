$file=$args[0];
forEach($id in bcdedit /store $file /enum /v | findstr -i identifier) {
    $start = $id.IndexOf("{");
    $end = $id.IndexOf("}");
    $val = $id.Substring($start, $end-$start+1);
    bcdedit /store $file /set $val bootems on;
    bcdedit /store $file /set $val ems on;
    bcdedit /store $file /set $val novga on
}
exit $LASTEXITCODE