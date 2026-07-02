@extends('layouts.app')
@section('content')
    <div class="container-fluid mt-3">

        @if ($config_file_exists)
            <div>
                <h4 class="bg-success text-center p-3 rounded mb-4">A Firebase config file already exists. To add new one
                    please follow
                    the
                    steps below. </h4>
            </div>
        @endif
        <div class="card shadow-none" style="border-color: rgba(231, 234, 243, 0.5019607843);">
            <div class="card-body">
                <div class="row g-4">
                    <!-- Step 1 -->
                    <div class="col-lg-6 col-xl-4">
                        <div class="export-steps-item h-100">
                            <div class="d-flex gap-3 justify-content-between align-items-center">
                                <div>
                                    <h3 class="fz-20 text-dark">Step 1</h3>
                                    <div>
                                        Login to your firebase account
                                    </div>
                                </div>
                                <img src="{{ asset('assets/images/firebase-login.png') }}" alt="" width="60">
                            </div>

                            <h4 class="mt-3 text-dark fz-20">Instruction</h4>

                            <ul class="m-0 pl-4">
                                <li>
                                    First of all, login to your firebase account.
                                </li>
                                <li>
                                    Then, create a new project in firebase or select an existing project.
                                </li>
                                <li>
                                    Then, go to project settings.
                                </li>
                            </ul>
                        </div>
                    </div>

                    <!-- Step 2 -->
                    <div class="col-lg-6 col-xl-4">
                        <div class="export-steps-item h-100">
                            <div class="d-flex gap-3 justify-content-between align-items-center">
                                <div>
                                    <h3 class="fz-20 text-dark">Step 2</h3>
                                    <div>
                                        Generate new private key
                                    </div>
                                </div>
                                <img src="{{ asset('assets/images/firebase-download.png') }}" alt="" width="60">
                            </div>

                            <h4 class="mt-3 text-dark fz-20">Instruction</h4>

                            <ul class="m-0 pl-4">
                                <li>
                                    Go to <strong>Service account</strong> in project settings."
                                </li>
                                <li>
                                    Click on <strong>Generate new private key</strong> button.
                                </li>
                                <li>
                                    Then, click on <strong>Generate key</strong> button.
                                </li>
                            </ul>
                        </div>
                    </div>

                    <!-- Step 3 -->
                    <div class="col-lg-6 col-xl-4">
                        <div class="export-steps-item h-100">
                            <div class="d-flex gap-3 justify-content-between align-items-center">
                                <div>
                                    <h3 class="fz-20 text-dark">Step 3</h3>
                                    <div>
                                        Upload firebase Credential
                                    </div>
                                </div>
                                <img src="{{ asset('assets/images/firebase-upload.png') }}" alt="" width="60">
                            </div>

                            <h4 class="mt-3 text-dark fz-20">Instruction</h4>

                            <ul class="m-0 pl-4">
                                <li>
                                    Select or drag and drop your generate private key file here.
                                </li>
                                <li>
                                    Then, click on <strong>Upload</strong> button.
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card my-3">
            <div class="card-body text-center">
                <h4 class="text-muted mb-3">
                    {{ __('Select generated Json File') }}
                </h4>
                @role('root|admin')
                    <form action="{{ route('fcm.update') }}" method="POST" enctype="multipart/form-data">
                        @csrf
                        @method('put')
                    @endrole

                    <div class="drop-zone mx-auto">
                        <span class="drop-zone__prompt">
                            <div class="icon">
                                <i class="fa-solid fa-cloud-arrow-up"></i>
                            </div>
                            {{ __('Drop file here or click to upload') }}
                        </span>
                        <input name="file" type="file" class="drop-zone__input" accept=".json">
                    </div>
                    @error('file')
                        <p class="text text-danger m-0">{{ $message }}</p>
                    @enderror

                    <div id="galler" style="display: none">
                        <button type="submit" class="btn btn-primary btn-lg mt-3 py-2">
                            {{ __('Upload File') }}
                        </button>
                    </div>
                    @role('root|admin')
                    </form>
                @endrole
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script src="{{ asset('assets/scripts/drop-zone.js') }}"></script>
    <script>
        $('input[name="file"]').change(function() {
            $('#galler').css('display', 'block');
        });
    </script>

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
