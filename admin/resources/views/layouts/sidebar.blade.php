<div id="sidebar-menu">

    <ul class="metismenu" id="side-menu">

        <li>
            <a href="{{ route('root') }}">
                <!-- <i class="fi-air-play"></i>  -->
                <img src="/assets/icons/dashboard.svg" alt="">
                <span> Dashboard </span>
            </a>
        </li>

        <li>
            <a href="{{ route('user.index') }}" class="{{ request()->routeIs('user.*') ? 'active' : '' }}">
                <!-- <i class="fa fa-user"></i>  -->
                <img src="/assets/icons/app-users.svg" alt="">
                <span> App Users</span>
            </a>
        </li>

        <li class="{{ request()->routeIs('category.*', 'albam.*', 'playlist.*', 'shift.*') ? 'active' : '' }}">
            <a href="javascript: void(0);"
                class="{{ request()->routeIs('category.*', 'albam.*', 'playlist.*', 'shift.*') ? 'active' : '' }}">
                <img src="/assets/icons/maditam.svg" alt="">
                <span> Maditam </span> <span class="menu-arrow"></span>
            </a>
            <ul class="nav-second-level" aria-expanded="false">
                <li class="{{ request()->routeIs('category.*') ? 'active' : '' }}">
                    <a href="{{ route('category.index') }}">Categories</a>
                </li>
                <li class="{{ request()->routeIs('albam.*') ? 'active' : '' }}">
                    <a href="{{ route('albam.index') }}">Albums</a>
                </li>
                <li class="{{ request()->routeIs('playlist.*') ? 'active' : '' }}">
                    <a href="{{ route('playlist.index') }}">Playlists</a>
                </li>
                <li class="{{ request()->routeIs('shift.*') ? 'active' : '' }}">
                    <a href="{{ route('shift.index') }}">Dashboard Category</a>
                </li>
            </ul>
        </li>

        <li>
            <a href="{{ route('banner.index') }}" class="{{ request()->routeIs('banner.*') ? 'active' : '' }}">
                
                <img src="/assets/icons/app-slider.svg" alt=""> 
                <span>App Slider</span>
            </a>
        </li>

        <li>
            <a href="{{ route('notification.index') }}"
                class="{{ request()->routeIs('notification.*') ? 'active' : '' }}">
                
                <img src="/assets/icons/notification-panel.svg" alt=""> 
                <span>Notification Panel</span>
            </a>
        </li>

        @php
        $websetting = App\Models\WebSetting::first();
        @endphp

        @if (!$websetting?->subscription)
        <li>
            <a href="{{ route('subscriptionPlan.index') }}"
                class="{{ request()->routeIs('subscriptionPlan.*') ? 'active' : '' }}">
                
                <img src="/assets/icons/subscription-plan.svg" alt=""> 
                <span> Subscription Plans</span>
            </a>
        </li>
        @endif

        <li class="{{ request()->routeIs('webSetting.*', 'mailConfig.*', 'fcm.*', 'smsConfig.*') ? 'active' : '' }}">
            <a href="javascript: void(0);"
                class="{{ request()->routeIs('webSetting.*', 'mailConfig.*', 'fcm.*') ? 'active' : '' }}">
                
                <img src="/assets/icons/configuration.svg" alt="">  
                <span> Configuration </span> <span class="menu-arrow"></span>
            </a>
            <ul class="nav-second-level" aria-expanded="false">
                <li class="{{ request()->routeIs('webSetting.*') ? 'active' : '' }}">
                    <a href="{{ route('webSetting.index') }}">Admin config</a>
                </li>
                <li class="{{ request()->routeIs('smsConfig.*') ? 'active' : '' }}">
                    <a href="{{ route('smsConfig.index') }}">SMS config</a>
                </li>
                <li class="{{ request()->routeIs('mailConfig.*') ? 'active' : '' }}">
                    <a href="{{ route('mailConfig.index') }}">SMTP Config</a>
                </li>
                <li class="{{ request()->routeIs('fcm.*') ? 'active' : '' }}">
                    <a href="{{ route('fcm.index') }}">FCM Config</a>
                </li>
            </ul>
        </li>

        <li class="{{ request()->routeIs('setting.*') ? 'active' : '' }}">
            <a href="javascript: void(0);" class="{{ request()->routeIs('setting.*') ? 'active' : '' }}">
                <img src="/assets/icons/setting.svg" alt=""> 
                <span> Generale Setting </span> <span class="menu-arrow"></span>
            </a>
            <ul class="nav-second-level" aria-expanded="false">
                @foreach (config('acl.settings') as $index => $item)
                <li class="nav-item">
                    <a href="{{ route('setting.show', $index) }}">{{ $item }}</a>
                </li>
                @endforeach

            </ul>
        </li>

    </ul>
</div>