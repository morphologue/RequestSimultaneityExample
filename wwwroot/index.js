function request() {
    return new Promise(resolve => {
        const xhr = new XMLHttpRequest();
        xhr.addEventListener('load', () => {
            const endTime = performance.now();
            resolve({ startTime, endTime });
        });
        xhr.open('POST', 'https://localhost:44360/sink');
        const startTime = performance.now();
        xhr.send();
    });
}

function* spamRequests(numRequests) {
    for (let i = 0; i < numRequests; i++) {
        yield request();
    }
}

function analyse(results) {
    const startTimes = results.map(r => r.startTime)
    const endTimes = results.map(r => r.endTime);
    const durations = results.map(r => r.endTime - r.startTime);

    const minStartTime = Math.min(...startTimes);
    const maxEndTime = Math.max(...endTimes);

    return {
        minDurationMs: Math.min(...durations),
        maxDurationMs: Math.max(...durations),
        avgDurationMs: durations.reduce((prev, cur) => prev + cur, 0) / durations.length,
        latestStartOffsetMs: Math.max(...startTimes) - minStartTime,
        overallDurationMs: maxEndTime - minStartTime
    };
}

function display(obj) {
    document.body.innerHTML = '<table><tbody><tr><th>Key</th><th>Value</th></tr></tbody></table>';
    const tbody = document.querySelector('tbody');
    for(const key in obj) {
        const keyTd = document.createElement('td'), valueTd = document.createElement('td');
        keyTd.textContent = key;
        valueTd.textContent = obj[key];

        const row = document.createElement('tr');
        row.append(keyTd, valueTd);
        tbody.append(row);
    }
}

async function drive() {
    const results = await Promise.all(spamRequests(100));
    const analysis = analyse(results);
    display(analysis);
}

drive();
