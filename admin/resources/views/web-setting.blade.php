@extends('layouts.app')
@section('content')
    <div class="container-fluid">
        <div class="row h-100vh align-items-center">
            <div class="col-md-10 col-lg-9 col-sm-12 m-auto">
                @role('root|admin')
                    <form action="{{ route('webSetting.update', $websetting?->id) }}" method="POST" enctype="multipart/form-data">
                        @csrf
                    @endrole
                    <div class="card shadow-sm">
                        <div class="card-header bg-custom py-2">
                            <h3 class="text-white m-0">Admin Configuration</h3>
                        </div>
                        <div class="card-body pb-3">
                            <div class="row">
                                <div class="col-md-6 border-right">
                                    <div class="mb-2">
                                        <label class="mb-0 text-dark">App Name <span class="text-danger">*</span></label>
                                        <input type="text" name="name" class="form-control"
                                            value="{{ $websetting?->name }}">
                                        @error('name')
                                            <small class="text-danger d-block">{{ $message }}</small>
                                        @enderror
                                    </div>

                                    <div class="mb-2">
                                        <label class="mb-0 text-dark">App title </label>
                                        <input type="text" name="title" class="form-control"
                                            value="{{ $websetting?->title }}" required>
                                    </div>

                                    <div class="mb-2">
                                        <label class="mb-0 text-dark">Theme Name </label>
                                        <select name="theme_name" class="form-control" id="">
                                            <option value="base"
                                                {{ $websetting?->theme_name == 'base' ? 'selected' : '' }}>base</option>
                                            <option value="blue_marguerite"
                                                {{ $websetting?->theme_name == 'blue_marguerite' ? 'selected' : '' }}>
                                                blue_marguerite</option>
                                            <option value="dodger_blu"
                                                {{ $websetting?->theme_name == 'dodger_blu' ? 'selected' : '' }}>dodger_blu
                                            </option>
                                            <option value="indigo"
                                                {{ $websetting?->theme_name == 'indigo' ? 'selected' : '' }}>indigo</option>
                                            <option value="gossamer"
                                                {{ $websetting?->theme_name == 'gossamer' ? 'selected' : '' }}>gossamer
                                            </option>
                                            <option value="sushi"
                                                {{ $websetting?->theme_name == 'sushi' ? 'selected' : '' }}>sushi</option>
                                            <option value="golden_bell"
                                                {{ $websetting?->theme_name == 'golden_bell' ? 'selected' : '' }}>
                                                golden_bell</option>
                                            <option value="cerise_red"
                                                {{ $websetting?->theme_name == 'cerise_red' ? 'selected' : '' }}>cerise_red
                                            </option>
                                            <option value="toast"
                                                {{ $websetting?->theme_name == 'toast' ? 'selected' : '' }}>toast</option>
                                            <option value="smalt_blue"
                                                {{ $websetting?->theme_name == 'smalt_blue' ? 'selected' : '' }}>smalt_blue
                                            </option>
                                            <option value="fuchsia_pink"
                                                {{ $websetting?->theme_name == 'fuchsia_pink' ? 'selected' : '' }}>
                                                fuchsia_pink</option>

                                        </select>
                                    </div>

                                    <div class="mb-2">
                                        <label class="mb-0 text-dark">App Logo</label>
                                        <input type="file" name="logo" class="form-control-file" accept="image/png"
                                            onchange="previewLogoFile(event)">
                                        @error('logo')
                                            <span class="text-danger d-block">{{ $message }}</span>
                                        @enderror
                                        <img class="mt-1"
                                            src="{{ $websetting?->logoPath ?? asset('web/images/logo.png') }}"
                                            alt="" id="logoPreview" height="50">
                                    </div>

                                    <div class="mb-2">
                                        <label class="mb-0 text-dark">Login page subtitle <span
                                                class="text-danger">*</span></label>
                                        <textarea name="subtitle" class="form-control" rows="2" placeholder="Login page subtitle ">{{ $websetting?->subtitle }}</textarea>
                                    </div>

                                    <div>
                                        <span class="">Subscription Enable/Disable</span>
                                    </div>
                                    @role('root|admin')
                                        <a class="subscriptionBtn border {{ $websetting?->subscription ? '' : 'border-custom' }}"
                                            href="{{ route('webSetting.toggle', $websetting?->id) }}">
                                        @else
                                            <a class="subscriptionBtn border {{ $websetting?->subscription ? '' : 'border-custom' }}"
                                                href="javascript:void(0)">
                                            @endrole
                                            <h4 class="m-0">Subscription
                                                {{ $websetting?->subscription ? 'Disable' : 'Enable' }}</h4>

                                            <div class="checkBox">
                                                <div class="dot"></div>
                                            </div>
                                            @if (!$websetting?->subscription)
                                                <div class="checkIcon">
                                                    <img class="icon" src="{{ asset('images/check.svg') }}">
                                                </div>
                                            @endif
                                        </a>
                                </div>
                                <div class="col-md-6">

                                    <div class="mb-3">
                                        <label class="mb-0 text-dark">favicon</label>
                                        <input type="file" name="fav_icon" class="form-control-file" accept="image/png"
                                            onchange="previewFavIco(event)">
                                        @error('fav_icon')
                                            <span class="text-danger d-block">{{ $message }}</span>
                                        @enderror
                                        <img class="mt-1"
                                            src="{{ $websetting?->favIconPath ?? asset('web/images/fav_icon.png') }}"
                                            alt="" id="favionPreview" height="40">
                                    </div>

                                    <div class="mb-2">
                                        <label class="mb-0 text-dark">Address <span class="text-danger">*</span></label>
                                        <textarea name="address" class="form-control" rows="3" placeholder="Address">{{ $websetting?->address }}</textarea>
                                    </div>

                                    <div class="mb-2">
                                        <label class="mb-0 text-dark">Mobile Number</label>
                                        <input type="text" name="mobile" class="form-control"
                                            value="{{ $websetting?->mobile }}" placeholder="Enter Mobile Number">
                                    </div>

                                    <div class="mb-2">
                                        <label class="mb-0 text-dark">Email Address</label>
                                        <input type="text" name="email" class="form-control"
                                            value="{{ $websetting?->email }}" placeholder="Enter Email Address">
                                    </div>

                                    <div class="">
                                        <label for="" class="mb-0 text-dark">Active Subscription</label>
                                        <select name="active_subscription" class="form-control">
                                            <option value="1"
                                                {{ $websetting?->active_subscription == 1 ? 'selected' : '' }}>Yes
                                            </option>
                                            <option value="0"
                                                {{ $websetting?->active_subscription == 0 ? 'selected' : '' }}>No
                                            </option>
                                        </select>
                                    </div>

                                    <div class="mt-3">
                                        <span class="">Ads Enable/Disable</span>
                                    </div>
                                    @role('root|admin')
                                        <a class="subscriptionBtn border {{ $websetting?->ads_show ? 'border-custom' : '' }}"
                                            href="{{ route('webSetting.toggle.ads', $websetting?->id) }}">
                                        @else
                                            <a class="subscriptionBtn border {{ $websetting?->ads_show ? 'border-custom' : '' }}"
                                                href="javascript:void(0)">
                                            @endrole
                                            <h4 class="m-0">Ads Show
                                                {{ $websetting?->ads_show ? 'Enable' : 'Disable' }}</h4>

                                            <div class="checkBox">
                                                <div class="dot"></div>
                                            </div>
                                            @if ($websetting?->ads_show)
                                                <div class="checkIcon">
                                                    <img class="icon" src="{{ asset('images/check.svg') }}">
                                                </div>
                                            @endif
                                        </a>

                                </div>
                            </div>

                        </div>
                        <div class="card-footer bg-white py-3 ">
                            <div class="d-flex justify-content-end">
                                {{-- @if (config('app.env') == 'local')
                                    <button type="button" onclick="showAlert('You can not update the general settings in demo mode')" class="btn btn-lg btn-custom rounded-0">Save And Update</button>
                                @else --}}
                                <button  class="btn btn-lg btn-custom rounded-0">Save And Update</button>
                                {{-- @endif --}}
                            </div>
                        </div>
                    </div>
                    @role('root|admin')
                    </form>
                @endrole
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        var previewLogoFile = function(event) {
            var reader = new FileReader();
            reader.onload = function() {
                var output = document.getElementById('logoPreview');
                output.src = reader.result;
            };
            reader.readAsDataURL(event.target.files[0]);
        };

        var previewFavIco = function(event) {
            var reader = new FileReader();
            reader.onload = function() {
                var output = document.getElementById('favionPreview');
                output.src = reader.result;
            };
            reader.readAsDataURL(event.target.files[0]);
        };

        var previewSignature = function(event) {
            var reader = new FileReader();
            reader.onload = function() {
                var output = document.getElementById('signaturePreview');
                output.src = reader.result;
            };
            reader.readAsDataURL(event.target.files[0]);
        };
    </script>
@endpush
