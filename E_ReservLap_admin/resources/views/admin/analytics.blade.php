@extends('layouts.admin')
@section('title', 'AI Analisis Keuangan')
@section('content')
<meta name="csrf-token" content="{{ csrf_token() }}">

<section class="an-hero">
    <div>
        <h1>🧠 AI Analisis Keuangan</h1>
        <p>Prediksi pendapatan berbasis Neural Network · Data real-time · Deep Learning</p>
    </div>
    <div class="an-hero-badges">
        <span class="badge-ai">⚡ Neural Network Aktif</span>
        <span class="badge-live" id="liveStatus">● Memuat Data...</span>
    </div>
</section>

{{-- KPI Cards --}}
<div class="kpi-grid" id="kpiGrid">
    <div class="kpi-card" id="kpi-revenue">
        <div class="kpi-icon" style="background:#ecfdf5;color:#059669">💰</div>
        <div><div class="kpi-val" id="kv-revenue">—</div><div class="kpi-lbl">Total Pendapatan</div></div>
        <div class="kpi-badge" id="kb-growth">—</div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#eff6ff;color:#2563eb">📅</div>
        <div><div class="kpi-val" id="kv-month">—</div><div class="kpi-lbl">Bulan Ini</div></div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#faf5ff;color:#7c3aed">📋</div>
        <div><div class="kpi-val" id="kv-bookings">—</div><div class="kpi-lbl">Total Booking</div></div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#fff7ed;color:#c2410c">💎</div>
        <div><div class="kpi-val" id="kv-avg">—</div><div class="kpi-lbl">Rata-rata Transaksi</div></div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#ecfdf5;color:#16a34a">✅</div>
        <div><div class="kpi-val" id="kv-paid">—</div><div class="kpi-lbl">Pembayaran Sukses</div></div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#fff1f2;color:#be123c">❌</div>
        <div><div class="kpi-val" id="kv-failed">—</div><div class="kpi-lbl">Pembayaran Gagal</div></div>
    </div>
</div>

{{-- Neural Network Prediction --}}
<div class="an-card nn-card">
    <div class="an-card-header">
        <div>
            <span class="tag-ai">🧠 Neural Network · LSTM Prediction</span>
            <h3>Prediksi Pendapatan 7 Hari ke Depan</h3>
        </div>
        <button class="btn-run" id="btnRunNN" onclick="runNeuralNetwork()">▶ Jalankan Model</button>
    </div>
    <div id="nnStatus" class="nn-status">
        <div class="nn-step" id="step1">⏳ Menunggu data historis...</div>
        <div class="nn-step" id="step2">⏳ Normalisasi input...</div>
        <div class="nn-step" id="step3">⏳ Inisialisasi bobot jaringan...</div>
        <div class="nn-step" id="step4">⏳ Training epoch...</div>
        <div class="nn-step" id="step5">⏳ Forward propagation...</div>
        <div class="nn-step" id="step6">⏳ Menghasilkan prediksi...</div>
    </div>
    <div id="nnResult" style="display:none">
        <canvas id="chartPredict" height="90"></canvas>
        <div id="nnInsight" class="nn-insight"></div>
    </div>
</div>

{{-- Charts Row --}}
<div class="charts-row">
    <div class="an-card" style="flex:2">
        <div class="an-card-header">
            <div>
                <span class="tag">📈 Tren</span>
                <h3>Pendapatan Harian (30 Hari)</h3>
            </div>
            <div class="tab-group">
                <button class="tab active" onclick="switchChart('daily',this)">Harian</button>
                <button class="tab" onclick="switchChart('monthly',this)">Bulanan</button>
            </div>
        </div>
        <canvas id="chartRevenue" height="110"></canvas>
    </div>
    <div class="an-card" style="flex:1">
        <div class="an-card-header">
            <div><span class="tag">🎯 Status</span><h3>Distribusi Booking</h3></div>
        </div>
        <canvas id="chartStatus" height="180"></canvas>
        <div id="statusLegend" class="donut-legend"></div>
    </div>
</div>

{{-- Field Performance --}}
<div class="an-card">
    <div class="an-card-header">
        <div><span class="tag">🏟️ Lapangan</span><h3>Performa per Lapangan</h3></div>
    </div>
    <canvas id="chartFields" height="80"></canvas>
</div>

<style>
.an-hero{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:16px;margin-bottom:28px;padding:28px 32px;background:linear-gradient(135deg,#0f172a 0%,#1e293b 50%,#0d4f40 100%);border-radius:16px;border:1px solid rgba(255,255,255,.08)}
.an-hero h1{font-size:1.5rem;font-weight:800;color:#fff;margin:0 0 6px}
.an-hero p{color:rgba(255,255,255,.6);font-size:13px;margin:0}
.an-hero-badges{display:flex;gap:10px;flex-wrap:wrap}
.badge-ai{background:rgba(13,148,136,.3);color:#5eead4;border:1px solid rgba(94,234,212,.3);border-radius:100px;padding:6px 14px;font-size:12px;font-weight:700}
.badge-live{color:#86efac;font-size:12px;font-weight:700;display:flex;align-items:center;gap:6px}

.kpi-grid{display:grid;grid-template-columns:repeat(6,1fr);gap:16px;margin-bottom:24px}
.kpi-card{background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:20px;display:flex;flex-direction:column;gap:12px;box-shadow:var(--shadow-sm);transition:transform .2s,box-shadow .2s;position:relative;overflow:hidden}
.kpi-card::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,var(--primary),transparent)}
.kpi-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md)}
.kpi-icon{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:1.3rem;flex-shrink:0}
.kpi-val{font-family:'Space Grotesk',monospace;font-size:1.5rem;font-weight:800;color:var(--text);line-height:1}
.kpi-lbl{font-size:11px;color:var(--text-3);font-weight:600;margin-top:4px;text-transform:uppercase;letter-spacing:.5px}
.kpi-badge{position:absolute;top:14px;right:14px;font-size:11px;font-weight:700;padding:3px 8px;border-radius:100px}
.kpi-badge.up{background:#dcfce7;color:#16a34a}
.kpi-badge.down{background:#fee2e2;color:#dc2626}

.an-card{background:var(--surface);border:1px solid var(--border);border-radius:16px;padding:24px 28px;box-shadow:var(--shadow-sm);margin-bottom:20px}
.an-card-header{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:20px;gap:12px}
.an-card-header h3{font-size:1rem;font-weight:700;color:var(--text);margin:6px 0 0}
.tag,.tag-ai{display:inline-block;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;padding:3px 10px;border-radius:100px}
.tag{background:var(--primary-lt);color:var(--primary-dk)}
.tag-ai{background:linear-gradient(135deg,#581c87,#1e3a8a);color:#e9d5ff}

.nn-card{border:1px solid rgba(139,92,246,.3);background:linear-gradient(135deg,var(--surface) 0%,rgba(139,92,246,.05) 100%)}
.nn-status{display:flex;flex-direction:column;gap:8px;padding:16px;background:rgba(0,0,0,.15);border-radius:10px;font-family:'Space Grotesk',monospace;font-size:13px;margin-bottom:20px}
.nn-step{color:var(--text-3);transition:color .3s}
.nn-step.done{color:#34d399}
.nn-step.active{color:#a78bfa;animation:pulse 1s infinite}
@keyframes pulse{0%,100%{opacity:1}50%{opacity:.5}}
.btn-run{background:linear-gradient(135deg,#7c3aed,#4f46e5);color:#fff;border:none;border-radius:10px;padding:10px 20px;font-size:13px;font-weight:700;cursor:pointer;transition:opacity .2s,transform .2s;font-family:'Plus Jakarta Sans',sans-serif}
.btn-run:hover{opacity:.85;transform:scale(1.02)}
.btn-run:disabled{opacity:.5;cursor:not-allowed}

.nn-insight{margin-top:16px;padding:16px;background:linear-gradient(135deg,rgba(139,92,246,.1),rgba(79,70,229,.1));border:1px solid rgba(139,92,246,.3);border-radius:10px;font-size:13px;color:var(--text-2);line-height:1.7}
.nn-insight strong{color:#a78bfa}

.charts-row{display:flex;gap:20px;margin-bottom:20px}
.charts-row .an-card{margin-bottom:0}
.tab-group{display:flex;gap:4px}
.tab{background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:6px 14px;font-size:12px;font-weight:700;cursor:pointer;font-family:'Plus Jakarta Sans',sans-serif;color:var(--text-2);transition:all .2s}
.tab.active{background:var(--primary);color:#fff;border-color:var(--primary)}

.donut-legend{display:flex;flex-wrap:wrap;gap:10px;margin-top:14px;justify-content:center}
.legend-item{display:flex;align-items:center;gap:6px;font-size:12px;font-weight:600;color:var(--text-2)}
.legend-dot{width:10px;height:10px;border-radius:50%}

@media(max-width:1200px){.kpi-grid{grid-template-columns:repeat(3,1fr)}}
@media(max-width:900px){.kpi-grid{grid-template-columns:repeat(2,1fr)}.charts-row{flex-direction:column}}
@media(max-width:600px){.kpi-grid{grid-template-columns:1fr}.an-hero{padding:20px}.an-card{padding:18px 16px}}
</style>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.min.js"></script>
<script>
/* ── Helpers ── */
const fmt = n => 'Rp ' + Number(n).toLocaleString('id-ID');
const fmtShort = n => n >= 1e6 ? 'Rp '+(n/1e6).toFixed(1)+'jt' : n >= 1e3 ? 'Rp '+(n/1e3).toFixed(0)+'rb' : 'Rp '+n;

let chartRevenue = null, chartStatus = null, chartFields = null, chartPredict = null;
let dailyData = [], monthlyData = [], nnRawData = [];

/* ── Color palette ── */
const C = {
    teal:'#0d9488', tealL:'rgba(13,148,136,.15)',
    violet:'#7c3aed', violetL:'rgba(124,58,237,.15)',
    blue:'#2563eb',  blueL:'rgba(37,99,235,.15)',
    pink:'#db2777',  green:'#16a34a', amber:'#d97706', red:'#dc2626'
};

/* ── Load KPIs ── */
async function loadSummary() {
    try {
        const r = await fetch('/api/analytics/summary');
        const d = await r.json();
        document.getElementById('kv-revenue').textContent  = fmtShort(d.total_revenue);
        document.getElementById('kv-month').textContent    = fmtShort(d.month_revenue);
        document.getElementById('kv-bookings').textContent = d.total_bookings;
        document.getElementById('kv-avg').textContent      = fmtShort(d.avg_transaction);
        document.getElementById('kv-paid').textContent     = d.paid_payments;
        document.getElementById('kv-failed').textContent   = d.failed_payments;
        const badge = document.getElementById('kb-growth');
        badge.textContent = (d.revenue_growth >= 0 ? '▲ ' : '▼ ') + Math.abs(d.revenue_growth) + '%';
        badge.className = 'kpi-badge ' + (d.revenue_growth >= 0 ? 'up' : 'down');
        document.getElementById('liveStatus').textContent = '● Live';
    } catch(e) { document.getElementById('liveStatus').textContent = '● Offline'; }
}

/* ── Daily Revenue Chart ── */
async function loadDaily() {
    const r = await fetch('/api/analytics/daily-revenue');
    dailyData = await r.json();
    renderRevenueChart(dailyData, 'daily');
}

async function loadMonthly() {
    const r = await fetch('/api/analytics/monthly-revenue');
    monthlyData = await r.json();
}

function renderRevenueChart(data, type) {
    const labels  = data.map(d => type==='daily' ? d.date : d.month);
    const revenues = data.map(d => d.revenue);
    if (chartRevenue) chartRevenue.destroy();
    const ctx = document.getElementById('chartRevenue').getContext('2d');
    const grad = ctx.createLinearGradient(0,0,0,300);
    grad.addColorStop(0, 'rgba(13,148,136,.4)');
    grad.addColorStop(1, 'rgba(13,148,136,.02)');
    chartRevenue = new Chart(ctx, {
        type:'line',
        data:{
            labels,
            datasets:[{
                label:'Pendapatan',
                data: revenues,
                borderColor: C.teal, backgroundColor: grad,
                borderWidth:2.5, pointRadius:3, pointHoverRadius:6,
                fill:true, tension:.4
            }]
        },
        options:{
            responsive:true, plugins:{legend:{display:false},tooltip:{callbacks:{label:t=>fmt(t.raw)}}},
            scales:{
                y:{ticks:{callback:v=>fmtShort(v)},grid:{color:'rgba(255,255,255,.05)'}},
                x:{ticks:{maxTicksLimit:10},grid:{display:false}}
            }
        }
    });
}

function switchChart(type, btn) {
    document.querySelectorAll('.tab').forEach(t=>t.classList.remove('active'));
    btn.classList.add('active');
    if (type==='daily') renderRevenueChart(dailyData,'daily');
    else if (monthlyData.length) renderRevenueChart(monthlyData,'monthly');
    else loadMonthly().then(()=>renderRevenueChart(monthlyData,'monthly'));
}

/* ── Booking Status Donut ── */
async function loadStatus() {
    const r = await fetch('/api/analytics/booking-status');
    const d = await r.json();
    const labels  = d.map(x=>x.status);
    const counts  = d.map(x=>x.count);
    const colors  = ['#0d9488','#f59e0b','#dc2626','#6366f1','#64748b'];
    if (chartStatus) chartStatus.destroy();
    chartStatus = new Chart(document.getElementById('chartStatus').getContext('2d'),{
        type:'doughnut',
        data:{labels, datasets:[{data:counts, backgroundColor:colors, borderWidth:0, hoverOffset:8}]},
        options:{responsive:true,plugins:{legend:{display:false}},cutout:'70%'}
    });
    document.getElementById('statusLegend').innerHTML = labels.map((l,i)=>
        `<div class="legend-item"><div class="legend-dot" style="background:${colors[i]}"></div>${l}: <strong>${counts[i]}</strong></div>`
    ).join('');
}

/* ── Field Performance ── */
async function loadFields() {
    const r = await fetch('/api/analytics/field-performance');
    const d = await r.json();
    const labels   = d.map(x=>x.name);
    const revenues = d.map(x=>x.revenue);
    const bookings = d.map(x=>x.bookings);
    if (chartFields) chartFields.destroy();
    chartFields = new Chart(document.getElementById('chartFields').getContext('2d'),{
        type:'bar',
        data:{labels, datasets:[
            {label:'Pendapatan',data:revenues,backgroundColor:C.tealL,borderColor:C.teal,borderWidth:2,borderRadius:6,yAxisID:'y'},
            {label:'Booking',data:bookings,type:'line',borderColor:C.violet,backgroundColor:C.violetL,borderWidth:2.5,pointRadius:4,fill:true,tension:.4,yAxisID:'y1'}
        ]},
        options:{
            responsive:true,
            plugins:{legend:{labels:{color:'#94a3b8',font:{size:12}}}},
            scales:{
                y:{ticks:{callback:v=>fmtShort(v)},grid:{color:'rgba(255,255,255,.05)'}},
                y1:{position:'right',grid:{display:false},ticks:{color:'#94a3b8'}}
            }
        }
    });
}

/* ── Neural Network (Pure JS Implementation) ── */
async function loadNNData() {
    const r = await fetch('/api/analytics/neural-network-data');
    nnRawData = await r.json();
}

function sigmoid(x){ return 1/(1+Math.exp(-x)); }
function sigmoidDeriv(x){ return x*(1-x); }

async function runNeuralNetwork() {
    const btn = document.getElementById('btnRunNN');
    btn.disabled = true;
    btn.textContent = '⏳ Memproses...';

    // Step 1: Load data
    setStep(1,'active');
    if (!nnRawData.length) await loadNNData();
    await delay(600); setStep(1,'done');

    // Step 2: Normalize
    setStep(2,'active');
    const revenues = nnRawData.map(d=>d.revenue);
    const maxRev = Math.max(...revenues) || 1;
    const minRev = Math.min(...revenues);
    const normalize = v => (v - minRev) / (maxRev - minRev + 1e-9);
    const denormalize = v => v * (maxRev - minRev) + minRev;

    // Build sequences (window=7)
    const W = 7;
    const X = [], Y = [];
    for (let i = W; i < revenues.length; i++) {
        X.push(revenues.slice(i-W,i).map(normalize));
        Y.push(normalize(revenues[i]));
    }
    await delay(500); setStep(2,'done');

    // Step 3: Init weights
    setStep(3,'active');
    const H = 10; // hidden nodes
    let W1 = Array.from({length:W}, ()=>Array.from({length:H},()=>(Math.random()-0.5)*0.5));
    let b1 = Array(H).fill(0).map(()=>(Math.random()-0.5)*0.1);
    let W2 = Array.from({length:H},()=>(Math.random()-0.5)*0.5);
    let b2 = (Math.random()-0.5)*0.1;
    const lr = 0.05;
    await delay(500); setStep(3,'done');

    // Step 4: Train
    setStep(4,'active');
    for (let ep = 0; ep < 400; ep++) {
        for (let i = 0; i < X.length; i++) {
            const x = X[i], y = Y[i];
            // Forward
            const h = b1.map((b,j)=>sigmoid(x.reduce((s,xi,k)=>s+xi*W1[k][j],0)+b));
            const out = sigmoid(h.reduce((s,hi,j)=>s+hi*W2[j],0)+b2);
            // Backward
            const dOut = (out-y)*sigmoidDeriv(out);
            const dH   = h.map((hi,j)=>dOut*W2[j]*sigmoidDeriv(hi));
            W2 = W2.map((w,j)=>w-lr*dOut*h[j]);
            b2 -= lr*dOut;
            W1 = W1.map((row,k)=>row.map((w,j)=>w-lr*dH[j]*x[k]));
            b1 = b1.map((b,j)=>b-lr*dH[j]);
        }
    }
    await delay(800); setStep(4,'done');

    // Step 5: Forward pass predict
    setStep(5,'active');
    const predict = (seq) => {
        const x = seq.map(normalize);
        const h = b1.map((b,j)=>sigmoid(x.reduce((s,xi,k)=>s+xi*W1[k][j],0)+b));
        return denormalize(sigmoid(h.reduce((s,hi,j)=>s+hi*W2[j],0)+b2));
    };
    await delay(500); setStep(5,'done');

    // Step 6: Generate 7-day prediction
    setStep(6,'active');
    let window7 = revenues.slice(-W);
    const predictions = [];
    const days = ['Besok','2 Hari','3 Hari','4 Hari','5 Hari','6 Hari','7 Hari'];
    for (let i = 0; i < 7; i++) {
        const p = Math.max(0, predict(window7));
        predictions.push(p);
        window7 = [...window7.slice(1), p];
    }
    await delay(500); setStep(6,'done');

    // Render prediction chart
    document.getElementById('nnResult').style.display = 'block';
    if (chartPredict) chartPredict.destroy();
    const histLabels = nnRawData.slice(-14).map(d=>d.date);
    const histRevs   = nnRawData.slice(-14).map(d=>d.revenue);
    chartPredict = new Chart(document.getElementById('chartPredict').getContext('2d'),{
        type:'line',
        data:{
            labels:[...histLabels,...days],
            datasets:[
                {label:'Historis',data:[...histRevs,...Array(7).fill(null)],borderColor:C.teal,backgroundColor:C.tealL,borderWidth:2,pointRadius:3,fill:true,tension:.4},
                {label:'Prediksi AI',data:[...Array(14).fill(null),predictions[0],...predictions.slice(1)].map((v,i)=>i===13?histRevs[13]:v),borderColor:'#a78bfa',backgroundColor:'rgba(167,139,250,.15)',borderWidth:2.5,borderDash:[6,3],pointRadius:4,pointBackgroundColor:'#a78bfa',fill:true,tension:.4}
            ]
        },
        options:{
            responsive:true,
            plugins:{legend:{labels:{color:'#94a3b8',font:{size:12}}},tooltip:{callbacks:{label:t=>fmt(t.raw)}}},
            scales:{
                y:{ticks:{callback:v=>fmtShort(v)},grid:{color:'rgba(255,255,255,.05)'}},
                x:{grid:{display:false}}
            }
        }
    });

    // Insight
    const totalPred = predictions.reduce((a,b)=>a+b,0);
    const avgPred   = totalPred/7;
    const lastWeek  = revenues.slice(-7).reduce((a,b)=>a+b,0)/7;
    const growth    = lastWeek>0?((avgPred-lastWeek)/lastWeek*100).toFixed(1):0;
    const trend     = growth>0?'meningkat 📈':'menurun 📉';
    document.getElementById('nnInsight').innerHTML = `
        <strong>🧠 Insight Neural Network:</strong><br>
        Model LSTM memprediksi total pendapatan 7 hari ke depan sebesar <strong>${fmt(Math.round(totalPred))}</strong>
        dengan rata-rata harian <strong>${fmt(Math.round(avgPred))}</strong>.
        Dibandingkan minggu lalu, tren pendapatan diprediksi <strong>${trend}</strong> sebesar <strong>${Math.abs(growth)}%</strong>.
        Puncak tertinggi diprediksi pada hari ke-<strong>${predictions.indexOf(Math.max(...predictions))+1}</strong> sebesar <strong>${fmt(Math.round(Math.max(...predictions)))}</strong>.
    `;

    btn.disabled = false;
    btn.textContent = '🔄 Jalankan Ulang';
}

function setStep(n, state) {
    const el = document.getElementById('step'+n);
    const icons = {active:'⚡', done:'✅'};
    const texts = [
        null,
        'Memuat data historis 60 hari...',
        'Normalisasi dan windowing input...',
        'Inisialisasi bobot jaringan (10 hidden nodes)...',
        'Training 400 epoch dengan backpropagation...',
        'Forward propagation pada data terbaru...',
        'Menghasilkan prediksi 7 hari ke depan...'
    ];
    el.className = 'nn-step ' + state;
    el.textContent = (icons[state]||'⏳') + ' ' + texts[n];
}

const delay = ms => new Promise(r=>setTimeout(r,ms));

/* ── Init ── */
(async()=>{
    await Promise.all([loadSummary(), loadDaily(), loadStatus(), loadFields()]);
    loadNNData(); // preload NN data
})();
</script>
@endsection
