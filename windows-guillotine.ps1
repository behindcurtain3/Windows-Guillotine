[reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

$lurkers = $null

function load-packages
{
    $data.Items.Clear()
    
    $lurkers = Get-AppxProvisionedPackage -online

    foreach($lurker in $lurkers)
    {
        $item = New-Object System.Windows.Forms.ListViewItem($lurker.DisplayName)
        $item.SubItems.Add($lurker.PackageName) | Out-Null

        $data.Items.Add($item) | Out-Null
    }

}

function remove-selected
{
    foreach($item in $data.SelectedItems)
    {
        Remove-AppxProvisionedPackage -PackageName $item.SubItems[1].Text -online
        Remove-AppxPackage -Package $item.SubItems[1].Text -allusers
    }

    load-packages
}

$form = New-Object System.Windows.Forms.Form
$form.Width = 500
$form.Height = 500
$form.Text = "Windows Guillotine"


$data = New-Object System.Windows.Forms.ListView
$data.Location = '15,15'
$data.Size = '450,400'
$data.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Left-bor [System.Windows.Forms.AnchorStyles]::Bottom
$data.View = 'Details'
$data.Columns.Add("Display Name").Width = 225
$data.Columns.Add("Package Name").Width = 200
$data.FullRowSelect = $true

$refreshBtn = New-Object System.Windows.Forms.Button
$refreshBtn.Location = '15,420'
$refreshBtn.Size = '150,35'
$refreshBtn.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom
$refreshBtn.Text = "Reload Package List"
$refreshBtn.Add_Click({
    load-packages
})

$removeBtn = New-Object System.Windows.Forms.Button
$removeBtn.Location = '175,420'
$removeBtn.Size = '290,35'
$removeBtn.Anchor = [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
$removeBtn.Text = "Removed Selected Packages"
$removeBtn.Add_Click({
    remove-selected
})


$form.Controls.Add($data)
$form.Controls.Add($refreshBtn)
$form.Controls.Add($removeBtn)

load-packages

$form.ShowDialog()
