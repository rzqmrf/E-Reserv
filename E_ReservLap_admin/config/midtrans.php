<?php

return [
    'merchant_id'   => env('MIDTRANS_MERCHANT_ID', 'M436570294'),
    'client_key'    => env('MIDTRANS_CLIENT_KEY', 'Mid-client-jiwn8ggvuDSUg4IY'),
    'server_key'    => env('MIDTRANS_SERVER_KEY', 'Mid-server-YTS2qwtPIE9MN6G6LxA83NKa'),
    'is_production' => env('MIDTRANS_IS_PRODUCTION', false),
    'is_sanitized'  => env('MIDTRANS_IS_SANITIZED', true),
    'is_3ds'        => env('MIDTRANS_IS_3DS', true),
];