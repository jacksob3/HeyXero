Promise = require("bluebird");
XeroConnection = require('./../../xero-connection');
numeral = require('numeral');

# note: this is not being used, aim is to try and call the other queries rather than recreate here

module.exports = {

  doRequest: () ->
    new Promise((resolve, reject) ->
      # https://api.xero.com/api.xro/2.0/reports/ProfitAndLoss?fromDate=2016-07-13
      XeroConnection().call 'GET', '/reports/ProfitAndLoss?fromDate=2016-07-13', null, (err, json) ->
        if(err)
          reject()
        else
          resolve(json)
    )

  createAnswer: (jsonResponse) ->

    console.log("Received: #{JSON.stringify(jsonResponse)}")

    # Filter and map to array of array
    rowsSection = jsonResponse.Response.Reports.Report.Rows.Row.filter((row) -> row.RowType == "Section" && row.Title == "Income" && row.Rows.Row[0].RowType == "Row")[0]
    cellRows = rowsSection.Rows.Row.filter((row) -> row.RowType == "SummaryRow").map((row) -> row.Cells.Cell)
    if (cellRows.length > 0)
      cellRows.map( (cellRow) ->
        {
          # First cell's Value
          KPIName: cellRow[0].Value
          # Last cell
          ThisMonthValue: cellRow.slice(-1)[0].Value
        }
      )

  formatAnswer: (answer) ->
    formattedAnswer = "SUMMARY TBA\n"
    answer.forEach((row) -> formattedAnswer = formattedAnswer + "#{row.KPIName}: #{numeral(row.ThisMonthValue).format('$0,0.00')}\n")
    formattedAnswer

}
