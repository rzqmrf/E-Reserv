@extends('layouts.admin')
@section('title', 'AI Analisis Keuangan')
@section('content')
<meta name="csrf-token" content="{{ csrf_token() }}">

<section class="an-hero">
    <div>
        <p class="eyebrow">AI Financial Intelligence</p>
        <h1>Prediksi pendapatan dan rekomendasi operasional</h1>
        <p class="hero-copy">Dashboard ini memakai data pembayaran paid, booking, dan performa lapangan untuk membaca tren 7 hari ke depan.</p>
    </div>
    <div class="hero-status">
        <span class="status-pill" id="aiStatus">Memeriksa AI service...</span>
        <span class="status-pill muted" id="modelStatus">Model belum dijalankan</span>
    </div>
</section>

<div class="kpi-grid" id="kpiGrid">
    <div class="kpi-card">
        <div class="kpi-top"><span class="kpi-icon money">Rp</span><span class="kpi-badge" id="kb-growth">-</span></div>
        <div class="kpi-val" id="kv-revenue">-</div>
        <div class="kpi-lbl">Total Pendapatan</div>
    </div>
    <div class="kpi-card">
        <div class="kpi-top"><span class="kpi-icon month">30</span></div>
        <div class="kpi-val" id="kv-month">-</div>
        <div class="kpi-lbl">Pendapatan Bulan Ini</div>
    </div>
    <div class="kpi-card">
        <div class="kpi-top"><span class="kpi-icon booking">Bk</span></div>
        <div class="kpi-val" id="kv-bookings">-</div>
        <div class="kpi-lbl">Total Booking</div>
    </div>
    <div class="kpi-card">
        <div class="kpi-top"><span class="kpi-icon avg">Avg</span></div>
        <div class="kpi-val" id="kv-avg">-</div>
        <div class="kpi-lbl">Rata-rata Transaksi</div>
    </div>
    <div class="kpi-card">
        <div class="kpi-top"><span class="kpi-icon paid">Ok</span></div>
        <div class="kpi-val" id="kv-paid">-</div>
        <div class="kpi-lbl">Pembayaran Sukses</div>
    </div>
    <div class="kpi-card">
        <div class="kpi-top"><span class="kpi-icon failed">No</span></div>
        <div class="kpi-val" id="kv-failed">-</div>
        <div class="kpi-lbl">Pembayaran Gagal</div>
    </div>
</div>

<div class="ai-grid">
    <section class="an-card ai-panel">
        <div class="an-card-header">
            <div>
                <span class="tag-ai">Prediction Engine</span>
                <h3>Prediksi Pendapatan 7 Hari</h3>
            </div>
            <button class="btn-run" id="btnRunNN" type="button" onclick="runPythonPrediction()">Jalankan AI</button>
        </div>

        <div class="model-metrics">
            <div>
                <span class="metric-label">Confidence</span>
                <strong id="metricConfidence">-</strong>
            </div>
            <div>
                <span class="metric-label">MAE</span>
                <strong id="metricMae">-</strong>
            </div>
            <div>
                <span class="metric-label">Training Samples</span>
                <strong id="metricSamples">-</strong>
            </div>
        </div>

        <div id="nnStatus" class="nn-status">
            <div class="nn-step" id="step1">Menunggu data historis</div>
            <div class="nn-step" id="step2">Menyiapkan fitur revenue, booking, dan kalender</div>
            <div class="nn-step" id="step3">Menghubungi AI service</div>
            <div class="nn-step" id="step4">Melatih model prediksi</div>
            <div class="nn-step" id="step5">Membaca insight dan rekomendasi</div>
        </div>

        <div id="nnResult" class="prediction-result">
            <canvas id="chartPredict" height="98"></canvas>
        </div>
    </section>

    <aside class="an-card insight-panel">
        <div class="an-card-header compact">
            <div>
                <span class="tag">AI Insight</span>
                <h3>Ringkasan Keputusan</h3>
            </div>
        </div>
        <div id="nnInsight" class="nn-insight empty">Jalankan model untuk melihat proyeksi, puncak pendapatan, dan rekomendasi admin.</div>
        <div class="recommendations" id="recommendations"></div>
    </aside>
</div>

<div class="charts-row">
    <section class="an-card revenue-card">
        <div class="an-card-header">
            <div>
                <span class="tag">Tren</span>
                <h3>Pendapatan Harian dan Bulanan</h3>
            </div>
            <div class="tab-group">
                <button class="tab active" type="button" onclick="switchChart('daily', this)">Harian</button>
                <button class="tab" type="button" onclick="switchChart('monthly', this)">Bulanan</button>
            </div>
        </div>
        <canvas id="chartRevenue" height="112"></canvas>
    </section>

    <section class="an-card status-card">
        <div class="an-card-header compact">
            <div>
                <span class="tag">Status</span>
                <h3>Distribusi Booking</h3>
            </div>
        </div>
        <canvas id="chartStatus" height="182"></canvas>
        <div id="statusLegend" class="donut-legend"></div>
    </section>
</div>

<section class="an-card">
    <div class="an-card-header">
        <div>
            <span class="tag">Lapangan</span>
            <h3>Performa per Lapangan</h3>
        </div>
    </div>
    <canvas id="chartFields" height="82"></canvas>
</section>

<style>
.an-hero{display:flex;align-items:flex-start;justify-content:space-between;gap:18px;flex-wrap:wrap;margin-bottom:24px;padding:26px 30px;background:#101827;border:1px solid rgba(255,255,255,.08);border-radius:14px;box-shadow:var(--shadow-sm)}
.eyebrow{margin:0 0 8px;color:#5eead4;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em}
.an-hero h1{max-width:760px;margin:0;color:#fff;font-size:1.55rem;font-weight:800;line-height:1.25}
.hero-copy{max-width:760px;margin:10px 0 0;color:rgba(255,255,255,.66);font-size:13px;line-height:1.7}
.hero-status{display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end}
.status-pill{display:inline-flex;align-items:center;border-radius:999px;padding:7px 12px;background:rgba(20,184,166,.16);border:1px solid rgba(94,234,212,.28);color:#99f6e4;font-size:12px;font-weight:800}
.status-pill.offline{background:rgba(245,158,11,.16);border-color:rgba(245,158,11,.34);color:#fcd34d}
.status-pill.muted{background:rgba(148,163,184,.14);border-color:rgba(148,163,184,.2);color:#cbd5e1}

.kpi-grid{display:grid;grid-template-columns:repeat(6,minmax(0,1fr));gap:14px;margin-bottom:20px}
.kpi-card{min-width:0;background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:18px;box-shadow:var(--shadow-sm)}
.kpi-top{height:34px;display:flex;align-items:flex-start;justify-content:space-between;gap:8px}
.kpi-icon{display:inline-flex;align-items:center;justify-content:center;min-width:34px;height:34px;border-radius:10px;font-size:11px;font-weight:900}
.kpi-icon.money,.kpi-icon.paid{background:#ecfdf5;color:#059669}.kpi-icon.month{background:#eff6ff;color:#2563eb}.kpi-icon.booking{background:#f5f3ff;color:#7c3aed}.kpi-icon.avg{background:#fff7ed;color:#c2410c}.kpi-icon.failed{background:#fff1f2;color:#be123c}
.kpi-val{font-family:'Space Grotesk',monospace;font-size:1.35rem;font-weight:800;color:var(--text);line-height:1.2;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.kpi-lbl{margin-top:5px;font-size:10px;color:var(--text-3);font-weight:800;text-transform:uppercase;letter-spacing:.06em}
.kpi-badge{font-size:11px;font-weight:800;padding:3px 8px;border-radius:999px;background:var(--bg);color:var(--text-3)}
.kpi-badge.up{background:#dcfce7;color:#15803d}.kpi-badge.down{background:#fee2e2;color:#dc2626}

.ai-grid{display:grid;grid-template-columns:minmax(0,1.7fr) minmax(280px,.8fr);gap:20px;margin-bottom:20px}
.an-card{min-width:0;background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:22px 24px;box-shadow:var(--shadow-sm);margin-bottom:20px}
.ai-grid .an-card,.charts-row .an-card{margin-bottom:0}
.an-card-header{display:flex;align-items:flex-start;justify-content:space-between;gap:14px;margin-bottom:18px}
.an-card-header.compact{margin-bottom:14px}
.an-card-header h3{margin:6px 0 0;color:var(--text);font-size:1rem;font-weight:800}
.tag,.tag-ai{display:inline-flex;border-radius:999px;padding:4px 10px;font-size:10px;font-weight:900;text-transform:uppercase;letter-spacing:.08em}
.tag{background:var(--primary-lt);color:var(--primary-dk)}.tag-ai{background:#312e81;color:#c4b5fd}
.btn-run{border:0;border-radius:10px;background:#0d9488;color:#fff;padding:10px 16px;font-family:'Plus Jakarta Sans',sans-serif;font-size:13px;font-weight:800;cursor:pointer;transition:transform .2s,opacity .2s}
.btn-run:hover{transform:translateY(-1px);opacity:.9}.btn-run:disabled{cursor:not-allowed;opacity:.55;transform:none}
.model-metrics{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin-bottom:14px}
.model-metrics div{background:var(--bg);border:1px solid var(--border);border-radius:10px;padding:12px}
.metric-label{display:block;margin-bottom:4px;color:var(--text-3);font-size:10px;font-weight:900;text-transform:uppercase;letter-spacing:.06em}
.model-metrics strong{color:var(--text);font-family:'Space Grotesk',monospace;font-size:1rem}
.nn-status{display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:8px;margin-bottom:18px}
.nn-step{min-height:48px;border:1px solid var(--border);border-radius:10px;padding:9px 10px;color:var(--text-3);font-size:11px;font-weight:700;line-height:1.35;background:var(--bg)}
.nn-step.active{border-color:#7c3aed;color:#7c3aed;background:rgba(124,58,237,.08)}.nn-step.done{border-color:#0d9488;color:#0d9488;background:rgba(13,148,136,.08)}
.prediction-result{min-height:220px}
.nn-insight{border:1px solid rgba(13,148,136,.2);border-radius:12px;background:rgba(13,148,136,.06);padding:14px;color:var(--text-2);font-size:13px;line-height:1.7}
.nn-insight.empty{border-color:var(--border);background:var(--bg);color:var(--text-3)}
.nn-insight strong{color:var(--text)}
.recommendations{display:flex;flex-direction:column;gap:10px;margin-top:12px}
.rec-item{border:1px solid var(--border);border-radius:10px;background:var(--bg);padding:11px 12px;color:var(--text-2);font-size:12px;font-weight:700;line-height:1.5}

.charts-row{display:grid;grid-template-columns:minmax(0,1.55fr) minmax(280px,.7fr);gap:20px;margin-bottom:20px}
.tab-group{display:flex;gap:6px;flex-wrap:wrap}.tab{border:1px solid var(--border);border-radius:8px;background:var(--bg);color:var(--text-2);padding:7px 12px;font-family:'Plus Jakarta Sans',sans-serif;font-size:12px;font-weight:800;cursor:pointer}.tab.active{background:var(--primary);border-color:var(--primary);color:#fff}
.donut-legend{display:flex;flex-wrap:wrap;gap:9px;margin-top:14px;justify-content:center}.legend-item{display:flex;align-items:center;gap:6px;color:var(--text-2);font-size:12px;font-weight:700}.legend-dot{width:10px;height:10px;border-radius:50%}
@media(max-width:1200px){.kpi-grid{grid-template-columns:repeat(3,minmax(0,1fr))}.ai-grid,.charts-row{grid-template-columns:1fr}.nn-status{grid-template-columns:repeat(3,minmax(0,1fr))}}
@media(max-width:700px){.kpi-grid,.model-metrics,.nn-status{grid-template-columns:1fr}.an-hero,.an-card{padding:18px}.an-card-header{flex-direction:column}.hero-status{justify-content:flex-start}.kpi-val{font-size:1.2rem}}
</style>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.min.js"></script>
<script>
const fmt = n => 'Rp ' + Math.round(Number(n || 0)).toLocaleString('id-ID');
const fmtShort = n => {
    n = Number(n || 0);
    if (n >= 1000000) return 'Rp ' + (n / 1000000).toFixed(1).replace('.', ',') + 'jt';
    if (n >= 1000) return 'Rp ' + Math.round(n / 1000) + 'rb';
    return 'Rp ' + Math.round(n);
};

let chartRevenue = null;
let chartStatus = null;
let chartFields = null;
let chartPredict = null;
let dailyData = [];
let monthlyData = [];
let nnRawData = [];

const C = {
    teal: '#0d9488',
    tealL: 'rgba(13,148,136,.15)',
    violet: '#7c3aed',
    violetL: 'rgba(124,58,237,.15)',
    blue: '#2563eb',
    amber: '#d97706',
    red: '#dc2626',
    slate: '#64748b'
};

async function fetchJson(url) {
    const response = await fetch(url, {headers: {'Accept': 'application/json'}});
    if (!response.ok) throw new Error('Gagal memuat ' + url);
    return response.json();
}

async function loadAIStatus() {
    const pill = document.getElementById('aiStatus');
    try {
        const data = await fetchJson('/api/analytics/ai-status');
        pill.textContent = data.online ? 'Python AI online' : 'Python AI offline';
        pill.classList.toggle('offline', !data.online);
    } catch (error) {
        pill.textContent = 'Python AI offline';
        pill.classList.add('offline');
    }
}

async function loadSummary() {
    const d = await fetchJson('/api/analytics/summary');
    document.getElementById('kv-revenue').textContent = fmtShort(d.total_revenue);
    document.getElementById('kv-month').textContent = fmtShort(d.month_revenue);
    document.getElementById('kv-bookings').textContent = d.total_bookings || 0;
    document.getElementById('kv-avg').textContent = fmtShort(d.avg_transaction);
    document.getElementById('kv-paid').textContent = d.paid_payments || 0;
    document.getElementById('kv-failed').textContent = d.failed_payments || 0;

    const badge = document.getElementById('kb-growth');
    const growth = Number(d.revenue_growth || 0);
    badge.textContent = (growth >= 0 ? '+' : '-') + Math.abs(growth) + '%';
    badge.className = 'kpi-badge ' + (growth >= 0 ? 'up' : 'down');
}

async function loadDaily() {
    dailyData = await fetchJson('/api/analytics/daily-revenue');
    renderRevenueChart(dailyData, 'daily');
}

async function loadMonthly() {
    monthlyData = await fetchJson('/api/analytics/monthly-revenue');
}

function renderRevenueChart(data, type) {
    const labels = data.map(d => type === 'daily' ? d.date : d.month);
    const revenues = data.map(d => Number(d.revenue || 0));
    if (chartRevenue) chartRevenue.destroy();

    const ctx = document.getElementById('chartRevenue').getContext('2d');
    const grad = ctx.createLinearGradient(0, 0, 0, 280);
    grad.addColorStop(0, 'rgba(13,148,136,.35)');
    grad.addColorStop(1, 'rgba(13,148,136,.02)');

    chartRevenue = new Chart(ctx, {
        type: 'line',
        data: {labels, datasets: [{label: 'Pendapatan', data: revenues, borderColor: C.teal, backgroundColor: grad, borderWidth: 2.5, pointRadius: 3, pointHoverRadius: 6, fill: true, tension: .36}]},
        options: {
            responsive: true,
            plugins: {legend: {display: false}, tooltip: {callbacks: {label: item => fmt(item.raw)}}},
            scales: {
                y: {ticks: {callback: value => fmtShort(value)}, grid: {color: 'rgba(148,163,184,.15)'}},
                x: {ticks: {maxTicksLimit: 10}, grid: {display: false}}
            }
        }
    });
}

async function switchChart(type, button) {
    document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
    button.classList.add('active');
    if (type === 'daily') {
        renderRevenueChart(dailyData, 'daily');
        return;
    }
    if (!monthlyData.length) await loadMonthly();
    renderRevenueChart(monthlyData, 'monthly');
}

async function loadStatus() {
    const data = await fetchJson('/api/analytics/booking-status');
    const labels = data.map(item => item.status || 'unknown');
    const counts = data.map(item => Number(item.count || 0));
    const colors = [C.teal, C.amber, C.red, C.violet, C.slate];

    if (chartStatus) chartStatus.destroy();
    chartStatus = new Chart(document.getElementById('chartStatus').getContext('2d'), {
        type: 'doughnut',
        data: {labels, datasets: [{data: counts, backgroundColor: colors, borderWidth: 0, hoverOffset: 8}]},
        options: {responsive: true, plugins: {legend: {display: false}}, cutout: '70%'}
    });

    document.getElementById('statusLegend').innerHTML = labels.map((label, index) =>
        `<div class="legend-item"><span class="legend-dot" style="background:${colors[index % colors.length]}"></span>${label}: <strong>${counts[index]}</strong></div>`
    ).join('');
}

async function loadFields() {
    const data = await fetchJson('/api/analytics/field-performance');
    const labels = data.map(item => item.name);
    const revenues = data.map(item => Number(item.revenue || 0));
    const bookings = data.map(item => Number(item.bookings || 0));

    if (chartFields) chartFields.destroy();
    chartFields = new Chart(document.getElementById('chartFields').getContext('2d'), {
        type: 'bar',
        data: {
            labels,
            datasets: [
                {label: 'Pendapatan', data: revenues, backgroundColor: C.tealL, borderColor: C.teal, borderWidth: 2, borderRadius: 6, yAxisID: 'y'},
                {label: 'Booking', data: bookings, type: 'line', borderColor: C.violet, backgroundColor: C.violetL, borderWidth: 2.5, pointRadius: 4, fill: true, tension: .36, yAxisID: 'y1'}
            ]
        },
        options: {
            responsive: true,
            plugins: {legend: {labels: {color: '#64748b', font: {size: 12}}}},
            scales: {
                y: {ticks: {callback: value => fmtShort(value)}, grid: {color: 'rgba(148,163,184,.15)'}},
                y1: {position: 'right', grid: {display: false}, ticks: {color: '#64748b'}}
            }
        }
    });
}

async function loadNNData() {
    nnRawData = await fetchJson('/api/analytics/neural-network-data');
}

async function runPythonPrediction() {
    const btn = document.getElementById('btnRunNN');
    btn.disabled = true;
    btn.textContent = 'Memproses...';
    resetSteps();

    try {
        setStep(1, 'active');
        if (!nnRawData.length) await loadNNData();
        await delay(180); setStep(1, 'done');

        setStep(2, 'active');
        await delay(180); setStep(2, 'done');

        setStep(3, 'active');
        const result = await fetchJson('/api/analytics/python-prediction');
        await loadAIStatus();
        await delay(180); setStep(3, 'done');

        setStep(4, 'active');
        renderPrediction(result);
        await delay(180); setStep(4, 'done');

        setStep(5, 'active');
        renderInsight(result);
        await delay(180); setStep(5, 'done');

        btn.textContent = 'Jalankan Ulang';
    } catch (error) {
        document.getElementById('nnInsight').className = 'nn-insight';
        document.getElementById('nnInsight').innerHTML = `<strong>AI belum dapat dijalankan.</strong><br>${error.message}`;
        btn.textContent = 'Jalankan AI';
    } finally {
        btn.disabled = false;
    }
}

function renderPrediction(result) {
    const history = result.history || nnRawData.slice(-14);
    const predictions = result.predictions || [];
    const histLabels = history.map(item => item.date);
    const histRevs = history.map(item => Number(item.revenue || 0));
    const predLabels = predictions.map(item => item.label);
    const predRevs = predictions.map(item => Number(item.revenue || 0));

    if (chartPredict) chartPredict.destroy();
    chartPredict = new Chart(document.getElementById('chartPredict').getContext('2d'), {
        type: 'line',
        data: {
            labels: [...histLabels, ...predLabels],
            datasets: [
                {label: 'Historis', data: [...histRevs, ...Array(predRevs.length).fill(null)], borderColor: C.teal, backgroundColor: C.tealL, borderWidth: 2, pointRadius: 3, fill: true, tension: .36},
                {label: 'Prediksi AI', data: [...Array(Math.max(histRevs.length - 1, 0)).fill(null), histRevs[histRevs.length - 1] || 0, ...predRevs], borderColor: C.violet, backgroundColor: C.violetL, borderWidth: 2.5, borderDash: [6, 3], pointRadius: 4, pointBackgroundColor: C.violet, fill: true, tension: .36}
            ]
        },
        options: {
            responsive: true,
            plugins: {legend: {labels: {color: '#64748b', font: {size: 12}}}, tooltip: {callbacks: {label: item => fmt(item.raw)}}},
            scales: {
                y: {ticks: {callback: value => fmtShort(value)}, grid: {color: 'rgba(148,163,184,.15)'}},
                x: {grid: {display: false}}
            }
        }
    });
}

function renderInsight(result) {
    const insight = result.insight || {};
    const model = result.model || {};
    const quality = model.quality || {};
    const sourceLabel = 'Python AI Service';

    document.getElementById('modelStatus').textContent = `${sourceLabel} - ${model.name || 'Model prediksi'}`;
    document.getElementById('metricConfidence').textContent = quality.confidence !== undefined ? quality.confidence + '%' : '-';
    document.getElementById('metricMae').textContent = quality.mae !== undefined ? fmtShort(quality.mae) : '-';
    document.getElementById('metricSamples').textContent = model.training_samples !== undefined ? model.training_samples : '-';

    const insightBox = document.getElementById('nnInsight');
    insightBox.className = 'nn-insight';
    insightBox.innerHTML = `
        <strong>${sourceLabel}</strong><br>
        Total prediksi 7 hari: <strong>${fmt(insight.total_prediction)}</strong><br>
        Rata-rata harian: <strong>${fmt(insight.average_daily)}</strong><br>
        Tren: <strong>${insight.trend || '-'}</strong> ${Number(insight.growth_percent || 0)}%<br>
        Puncak: <strong>${insight.peak_day || '-'}</strong> sebesar <strong>${fmt(insight.peak_revenue)}</strong>
    `;

    const recommendations = insight.recommendations || [];
    document.getElementById('recommendations').innerHTML = recommendations.map(item =>
        `<div class="rec-item">${item}</div>`
    ).join('');
}

function resetSteps() {
    for (let i = 1; i <= 5; i++) {
        document.getElementById('step' + i).className = 'nn-step';
    }
}

function setStep(index, state) {
    document.getElementById('step' + index).className = 'nn-step ' + state;
}

const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

(async () => {
    try {
        await Promise.all([loadAIStatus(), loadSummary(), loadDaily(), loadStatus(), loadFields()]);
        loadMonthly();
        loadNNData();
    } catch (error) {
        document.getElementById('aiStatus').textContent = 'Data analytics belum siap';
        document.getElementById('aiStatus').classList.add('offline');
    }
})();
</script>
@endsection
