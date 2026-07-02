@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">Category Edit</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">Edit category</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="row">
        <div class="col-md-10 col-lg-9 m-auto">
            @role('root|admin')
            <form action="{{ route('category.update', $category->id) }}" method="POST" enctype="multipart/form-data">
                @csrf
                @endrole
                <div class="card animate__animated animate__bounceInDown">
                    <div class="card-header bg-success py-2">
                        <h4 class="text-white">Edit Category</h4>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-8 border-right">
                                <x-input name="name" type="text" placeholder="Category Name"
                                    value="{{ $category->name }}"></x-input>
                                <x-textarea name="description" placeholder="Description"
                                    value="{{ $category->description }}" rows="4"></x-textarea>
                            </div>

                            <div class="col-lg-4">
                                <div class="form-group">
                                    <label class="mb-1">Thumbnail</label>
                                    <input type="file" class="form-control-file" name="thumbnail"
                                        onchange="previewLogoFile(event)" />
                                    <img src="{{ $category->thumbnail }}" id="logoPreview" width="140"
                                        height="150" class="mt-1">
                                </div>

                                <div class="form-group">
                                    <label class="mb-1">Category Icon</label>
                                    <input type="file" class="form-control-file" name="icon"
                                        onchange="previewIconFile(event)" />
                                    <img src="{{ $category->iconPath }}" alt="" id="iconPreview" width="60" class="mt-1">
                                </div>
                            </div>

                        </div>
                        <div class="d-flex align-items-center" style="gap: 4px">
                            <input type="checkbox" name="active" id="active" {{ $category->status ? 'checked' : '' }}>
                            <label class="m-0 p-0" for="active">Active</label>
                        </div>
                    </div>
                    <div class="card-footer d-flex justify-content-between bg-white">
                        <a href="{{ route('category.index') }}" type="button" class="btn btn-secondary text-white">
                            <i class="fa fa-arrow-left"></i> GO Back
                        </a>
                        <button type="submit" class="btn btn-success px-md-5">Submit</button>
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

        function previewIconFile(event) {
            var reader = new FileReader();
            reader.onload = function() {
                var output = document.getElementById('iconPreview');
                output.src = reader.result;
            };
            reader.readAsDataURL(event.target.files[0]);
        };
    </script>
@endpush
