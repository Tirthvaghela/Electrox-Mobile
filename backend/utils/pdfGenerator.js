const generateElectionResultsHTML = (electionData, resultsData) => {
  const { title, description, total_votes, total_voters } = electionData;
  const turnoutPercentage = total_voters > 0 ? ((total_votes / total_voters) * 100).toFixed(2) : 0;
  
  let candidateRows = '';
  resultsData.forEach((candidate, index) => {
    const percentage = total_votes > 0 ? ((candidate.votes / total_votes) * 100).toFixed(2) : 0;
    candidateRows += `
      <tr>
        <td>${index + 1}</td>
        <td>${candidate.name}</td>
        <td>${candidate.votes}</td>
        <td>${percentage}%</td>
      </tr>
    `;
  });
  
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>Election Results - ${title}</title>
      <style>
        body {
          font-family: 'Arial', sans-serif;
          margin: 40px;
          color: #333;
        }
        .header {
          text-align: center;
          border-bottom: 3px solid #14213D;
          padding-bottom: 20px;
          margin-bottom: 30px;
        }
        .header h1 {
          color: #14213D;
          margin: 0;
        }
        .header p {
          color: #666;
          margin: 5px 0;
        }
        .stats {
          display: flex;
          justify-content: space-around;
          margin: 30px 0;
        }
        .stat-box {
          text-align: center;
          padding: 20px;
          background: #f8f9fa;
          border-radius: 8px;
          min-width: 150px;
        }
        .stat-box h3 {
          margin: 0;
          color: #14213D;
          font-size: 32px;
        }
        .stat-box p {
          margin: 5px 0 0 0;
          color: #666;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin-top: 30px;
        }
        th, td {
          padding: 12px;
          text-align: left;
          border-bottom: 1px solid #ddd;
        }
        th {
          background: #14213D;
          color: white;
        }
        tr:hover {
          background: #f8f9fa;
        }
        .footer {
          margin-top: 50px;
          text-align: center;
          color: #666;
          font-size: 12px;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>🗳️ ${title}</h1>
        <p>${description}</p>
        <p>Generated on ${new Date().toLocaleString()}</p>
      </div>
      
      <div class="stats">
        <div class="stat-box">
          <h3>${total_votes}</h3>
          <p>Total Votes</p>
        </div>
        <div class="stat-box">
          <h3>${total_voters}</h3>
          <p>Total Voters</p>
        </div>
        <div class="stat-box">
          <h3>${turnoutPercentage}%</h3>
          <p>Turnout</p>
        </div>
      </div>
      
      <h2>Results</h2>
      <table>
        <thead>
          <tr>
            <th>Rank</th>
            <th>Candidate</th>
            <th>Votes</th>
            <th>Percentage</th>
          </tr>
        </thead>
        <tbody>
          ${candidateRows}
        </tbody>
      </table>
      
      <div class="footer">
        <p>© 2025 Electrox - Official Election Results</p>
      </div>
    </body>
    </html>
  `;
};

module.exports = { generateElectionResultsHTML };
