<?php

namespace Database\Seeders;

use App\Models\Field;
use Illuminate\Database\Seeder;

class FieldSeeder extends Seeder
{
    public function run(): void
    {
        $fields = [
            [
                'name' => 'Lapangan Futsal International',
                'foto_lapangan' => 'fields/J5f1BCQDkjHoleFmP6Ggzw0mWSXA2eS58oe6wGhF.png',
                'type' => 'Futsal',
                'price' => 150000,
                'capacity' => 10,
                'status' => 'available',
                'description' => 'Lapangan futsal dengan standar internasional dan rumput sintetis berkualitas tinggi.',
            ],
            [
                'name' => 'Lapangan Futsal Standard',
                'foto_lapangan' => 'fields/Wb2BL1Z8w4iBEN6ZpZkcWaGEZ1y7o7sl8kc3PGZq.jpg',
                'type' => 'Futsal',
                'price' => 100000,
                'capacity' => 10,
                'status' => 'available',
                'description' => 'Lapangan futsal standar dengan fasilitas lengkap.',
            ],
            [
                'name' => 'Lapangan Badminton 1',
                'foto_lapangan' => 'fields/hJIGkLaki1X9w8e4VeHzJ7BxFMIrZqyYAIU4MdqX.jpg',
                'type' => 'Badminton',
                'price' => 50000,
                'capacity' => 4,
                'status' => 'available',
                'description' => 'Lapangan badminton dengan lantai kayu parket.',
            ],
            [
                'name' => 'Lapangan Badminton 2',
                'foto_lapangan' => 'fields/pZIalRicsa5rNcshzlrf3zoFtSeIl12Tk8RHVXVd.png',
                'type' => 'Badminton',
                'price' => 50000,
                'capacity' => 4,
                'status' => 'available',
                'description' => 'Lapangan badminton dengan lantai vinyl standar BWF.',
            ],
            [
                'name' => 'Lapangan Basket',
                'foto_lapangan' => 'fields/p0W53wDWZ3aZda4O8xCNCsajobzCeeYaQjprQyem.jpg',
                'type' => 'Basket',
                'price' => 200000,
                'capacity' => 12,
                'status' => 'available',
                'description' => 'Lapangan basket indoor dengan ring standar NBA.',
            ],
        ];

        foreach ($fields as $field) {
            Field::create($field);
        }
    }
}
