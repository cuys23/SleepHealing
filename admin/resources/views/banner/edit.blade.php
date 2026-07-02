@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">App Slider Edit</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">Edit app slider</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="row">
        <div class="col-md-10 col-lg-9 m-auto">
            @role('root|admin')
            <form action="{{ route('banner.update', $banner->id) }}" method="POST" enctype="multipart/form-data">
                @csrf
                @endrole
                <div class="card">
                    <div class="card-header bg-success py-2">
                        <h4 class="text-white">Edit Slider</h4>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-8 border-right">
                                <x-input name="title" type="text" placeholder="Title"
                                    value="{{ $banner->title }}"></x-input>
                                <x-textarea name="description" placeholder="Description"
                                    value="{{ $banner->description }}" rows="4"></x-textarea>
                            </div>

                            <div class="col-lg-4">
                                <div class="form-group">
                                    <label class="mb-1">Thumbnail</label>
                                    <input type="file" class="form-control-file" name="thumbnail"
                                        onchange="previewLogoFile(event)" />
                                    <img src="{{ $banner->thumbnail }}" id="logoPreview" width="160"
                                        height="150" class="mt-1">
                                </div>
                            </div>

                        </div>
                        <div class="d-flex align-items-center" style="gap: 4px">
                            <input type="checkbox" name="status" id="active" {{ $banner->status ? 'checked' : '' }}>
                            <label class="m-0 p-0" for="active">Active</label>
                        </div>
                    </div>
                    <div class="card-footer d-flex justify-content-between bg-white">
                        <a href="{{ route('banner.index') }}" type="button" class="btn btn-secondary text-white">GO
                            Back</a>
                        <button type="submit" class="btn btn-success px-md-5">Submit</button>
                    </div>
                </div>
            @role('root|admin')</form> @endrole
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
    </script>
@endpush
