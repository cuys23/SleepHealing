@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">Playlist Create</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">Create new playlist</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="row">
        <div class="col-md-10 col-lg-9 m-auto">
            @role('root|admin')
            <form action="{{ route('playlist.update', $playlist->id) }}" method="POST" enctype="multipart/form-data">
                @csrf
                @endrole
                <div class="card">
                    <div class="card-header bg-success py-2">
                        <h4 class="text-white">Edit Playlist</h4>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-8 border-right">
                                <x-input name="name" type="text" placeholder="Name" value="{{ $playlist->name }}">
                                </x-input>
                                <x-input name="duration" type="text" placeholder="Duration"
                                    value="{{ $playlist->duration }}">
                                </x-input>
                                <x-textarea name="description" placeholder="Description"
                                    value="{{ $playlist->description }}" rows="4"></x-textarea>
                            </div>
                            <div class="col-lg-4">
                                <div class="form-group">
                                    <label class="mb-1">Thumbnail</label>
                                    <input type="file" class="form-control-file" name="thumbnail"
                                        onchange="previewLogoFile(event)" />
                                    <img src="{{ $playlist->thumbnail }}" alt="" id="logoPreview" width="160"
                                        height="160" class="mt-1">
                                </div>
                                <div class="form-group">
                                    <label class="mb-1">Audio File</label>
                                    <input type="file" class="form-control-file" name="audio"
                                        onchange="previewAudio(event)" />
                                </div>
                            </div>
                        </div>
                        <div class="d-flex align-items-center" style="gap: 40px">
                            <div class="d-flex align-items-center" style="gap: 4px">
                                <input type="checkbox" name="active" id="active" {{ $playlist->status ? 'checked' : '' }}>
                                <label class="m-0 p-0" for="active">Active</label>
                            </div>
                            <div class="d-flex align-items-center" style="gap: 4px">
                                <input type="checkbox" name="paid" id="paid" {{ $playlist->is_paid ? 'checked' : '' }}>
                                <label class="m-0 p-0" for="paid">Paid</label>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer d-flex justify-content-between bg-white">
                        <a href="{{ route('playlist.index') }}" type="button" class="btn btn-secondary text-white">
                            <i class="fa fa-arrow-left"></i> GO Back
                        </a>
                        <button type="submit" class="btn btn-success px-md-4">Save And Update</button>
                    </div>
                </div>
                @role('root|admin')</form>@endrole
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

        var previewAudio = function(event) {
            var reader = new FileReader();
            reader.onload = function() {
                var output = document.getElementById('audioPreview');
                output.src = reader.result;
            };
            reader.readAsDataURL(event.target.files[0]);
        };
    </script>
@endpush
