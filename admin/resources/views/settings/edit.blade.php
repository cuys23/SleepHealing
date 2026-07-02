@extends('layouts.app')

@section('content')
    <div class="container-fluid mt-5">
        <div class="col-sm-6 p-md-0  mt-2 mt-sm-0 d-flex">
            <a href="{{ route('setting.show', $setting->slug) }}" class="btn btn-custom">
                <i class="fa fa-arrow-left"></i> Back
            </a>
        </div>

        <div class="row">
            <div class="col-xl-12 col-xxl-12 col-lg-12 mt-4">
                @role('root|admin')
                    <form action="{{ route('setting.update', $setting->id) }}" method="POST" enctype="multipart/form-data">
                        @method('put')
                        @csrf
                    @endrole
                    <div class="card">
                        <div class="card-header bg-custom">
                            <h3 class="text-white m-0">Edit {{ $setting->title }}</h3>
                        </div>
                        <div class="card-body">
                            <x-input name='title' type="text" placeholder="Title" value="{{ $setting->title }}" />

                            <textarea class="form-control" id="editor" name="content" placeholder="Content">
                                {{ $setting->content }}
                            </textarea>
                            @error('content')
                                <span class="text-danger">{{ $message }}</span>
                            @enderror

                            <div class="mt-3 text-right">
                                <button class="btn btn-custom rounded-0" type="submit">Save And Updated</button>
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
    <script src="https://cdn.ckeditor.com/ckeditor5/30.0.0/classic/ckeditor.js"></script>

    <script>
        ClassicEditor
            .create(document.querySelector('#editor'))
            .catch(error => {
                console.error(error);
            });
    </script>

    <script>
        $('#name').keyup(function() {
            $('#slug').val($(this).val().toLowerCase().split(',').join('').replace(/\s/g, "-"));
        });
    </script>
@endpush
