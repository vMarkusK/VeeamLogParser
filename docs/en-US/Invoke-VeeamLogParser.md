---
external help file: Invoke-VeeamLogParser-help.xml
Module Name: VeeamLogParser
online version: https://mycloudrevolution.com/
schema: 2.0.0
---

# Invoke-VeeamLogParser

## SYNOPSIS

## SYNTAX

```
Invoke-VeeamLogParser [[-VeeamBasePath] <String>] [[-Context] <Int32>] [[-Limit] <Int32>] [-LogType] <String>
 [<CommonParameters>]
```

## DESCRIPTION
The Veeam Log Parser Function extracts Error and Warning Messages from the Veeam File Logs of various products and services.

## EXAMPLES

### EXAMPLE 1
```
Invoke-VeeamLogParser -LogType Endpoint -Limit 2
```

### EXAMPLE 2
```
Invoke-VeeamLogParser -LogType Endpoint -Limit 2 -Context 2
```

## PARAMETERS

### -VeeamBasePath
The Base Path of the Veeam Log Files

Default: "C:\ProgramData\Veeam\"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: C:\ProgramData\Veeam\
Accept pipeline input: False
Accept wildcard characters: False
```

### -Context
Show messages in Context

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Show limited number of messages

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogType
The products or services Log you want to show

Valid Pattern:  "All","Endpoint","Mount","Backup","EnterpriseServer","Broker","Catalog","RestAPI","BackupManager",
                "CatalogReplication","DatabaseMaintenance","WebApp","PowerShell"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
File Name  : Invoke-VeeamLogParser.psm1
Author     : Markus Kraus
Version    : 1.0
State      : Ready

## RELATED LINKS

[https://mycloudrevolution.com/](https://mycloudrevolution.com/)

