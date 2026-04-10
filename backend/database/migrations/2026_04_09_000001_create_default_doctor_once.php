<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

return new class extends Migration {
    public function up(): void
    {
        $phone = (string) env('DEFAULT_DOCTOR_PHONE', '77003255');
        $name = (string) env('DEFAULT_DOCTOR_NAME', 'Dr. Hugo Lagos');
        $password = (string) env('DEFAULT_DOCTOR_PASSWORD', 'hugo123');

        $person = DB::table('people')->where('phone', $phone)->first();
        if (!$person) {
            $personId = (string) Str::uuid();

            DB::table('people')->insert([
                'id' => $personId,
                'phone' => $phone,
                'name' => $name,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        } else {
            $personId = $person->id;
        }

        $doctor = DB::table('doctors')->where('person_id', $personId)->first();
        if (!$doctor) {
            DB::table('doctors')->insert([
                'id' => (string) Str::uuid(),
                'person_id' => $personId,
                'password_hash' => Hash::make($password),
                'active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        // Intencionalmente sin rollback para no borrar datos operativos.
    }
};
