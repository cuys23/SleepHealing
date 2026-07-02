<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingSeeder extends Seeder
{
    private static array $content = [
        'privacy-policy' => "Maditam respects your privacy. We collect only the information needed to provide our sleep and meditation services, such as your account details and listening preferences.\n\nWe never sell your personal data to third parties. Information you provide is used solely to improve your experience, personalize recommendations, and keep your account secure.\n\nYou can request a copy of your data or ask us to delete your account at any time by contacting our support team.\n\nWe use industry-standard security measures to protect your information, including encrypted storage and secure authentication.\n\nBy using Maditam, you agree to this privacy policy. We will notify you of any significant changes to how we handle your data.",
        'trams-of-service' => "By creating an account with Maditam, you agree to use the app for personal, non-commercial purposes only.\n\nContent available in the app, including audio tracks, stories, and meditations, is owned by Maditam or its licensors and may not be copied, redistributed, or resold.\n\nSubscription plans renew automatically unless cancelled before the renewal date. Refunds are handled according to the policies of the app store you subscribed through.\n\nWe reserve the right to suspend accounts that violate these terms, including sharing login credentials or attempting to access the service through unauthorized means.\n\nThese terms may be updated from time to time. Continued use of the app after changes are published means you accept the updated terms.",
        'contact-us' => "We'd love to hear from you. If you have questions, feedback, or need help with your account, reach out to our support team.\n\nEmail: support@maditam.com\nHours: Monday to Friday, 9:00 AM - 6:00 PM\n\nFor billing or subscription issues, please include your account email so we can assist you faster.\n\nYou can also find answers to common questions in the Help section of the app.",
        'about-us' => "Maditam was created to help people find calm in their everyday lives. Our library of sleep stories, guided meditations, and nature sounds is designed to help you relax, focus, and rest better.\n\nWhether you're winding down after a busy day, looking to build a mindfulness habit, or simply need a moment of quiet, Maditam is here to support you.\n\nOur team is made up of people who care deeply about well-being, and we're always working on new content to help our community sleep better and stress less.",
    ];

    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        foreach(config('acl.settings') as $key => $setting){
            Setting::create([
                'title' => $setting,
                'slug' => $key,
                'content' => self::$content[$key] ?? "Content for {$setting} will be available soon.",
            ]);
        }
    }
}
