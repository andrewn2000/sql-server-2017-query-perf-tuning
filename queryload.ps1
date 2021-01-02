
#Powershell script to create load
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = 'Server=NYCV-SQL17;Database=AdventureWorks2017;trusted_connection=true'
# Load Product data
$ProdCmd = New-Object System.Data.SqlClient.SqlCommand
$ProdCmd.CommandText = "SELECT ProductID FROM Production.Product"
$ProdCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $ProdCmd
$ProdDataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($ProdDataSet)
# Set up the procedure to be run
$WhereCmd = New-Object System.Data.SqlClient.SqlCommand
$WhereCmd.CommandText = "dbo.uspGetWhereUsedProductID @StartProductID = @ProductId, @CheckDate=NULL"
$WhereCmd.Parameters.Add("@ProductID",[System.Data.SqlDbType]"Int")
$WhereCmd.Connection = $SqlConnection
# And another one
$BomCmd = New-Object System.Data.SqlClient.SqlCommand
$BomCmd.CommandText = "dbo.uspGetBillOfMaterials @StartProductID = @ProductId, @CheckDate=NULL"
$BomCmd.Parameters.Add("@ProductID",[System.Data.SqlDbType]"Int")
$BomCmd.Connection = $SqlConnection
# Bad Query
$BadQuerycmd = New-Object System.Data.SqlClient.SqlCommand
$BadQuerycmd.CommandText = "dbo.uspProductSize"
$BadQuerycmd.Connection = $SqlConnection
while(1 -ne 0)
    {
    #$RefID = $row[0]
    $SqlConnection.Open()
    $BadQuerycmd.ExecuteNonQuery() | Out-Null
    $SqlConnection.Close()
        foreach($row in $ProdDataSet.Tables[0])
            {
            $SqlConnection.Open()
            $ProductId = $row[0]
            $BomCmd.Parameters["@ProductID"].Value = $ProductId
            $BomCmd.ExecuteNonQuery() | Out-Null
            $SqlConnection.Close()
            $SqlConnection.Open()
            $ProductId = $row[0]
            $WhereCmd.Parameters["@ProductID"].Value = $ProductId
            $WhereCmd.ExecuteNonQuery() | Out-Null
            $SqlConnection.Close()
            }
    }