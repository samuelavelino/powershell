Function Create-Directory ( $path ) {
    <#
    .SYNOPSIS
        Creates a directory.

    .DESCRIPTION
        The Create-Directory function creates any intermediate directories in the path, if needed.

    .PARAMETER Path
        Specifies the path where you want to create the new directory.

    .NOTES
        Version: 1.0 (2023-01-10)
        Author:  Samuel Avelino
        Contact: avelino.contactme+github(a)gmail.com
        Website: https://samuelavelino.github.io
    #>

    if ( [String]::IsNullOrWhiteSpace($path) ) {

        Message -Origin $MyInvocation -Type error -Text 'The $path argument is null or empty'

    }
    else {

        if ( Test-Path -LiteralPath $path -PathType Container ) {
            Message -Origin $MyInvocation -Type 'alert' -Text 'Directory already exists' -Value $path
        }
        else {
            try
            {
                $null = mkdir -Path $path -Force -ErrorAction STOP
                #new-item -type directory -path $path -Force
                Message -Origin $MyInvocation -Type 'success' -Text 'Directory was created' -Value $path
            }
            catch
            {
                Message -Origin $MyInvocation -Type 'error' -Text 'Directory not created' -Value $path
                Message -Origin $MyInvocation -Type 'error' -Value $_
            }
        }
    }

    return $path
}