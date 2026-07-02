@extends('layouts.app')

@section('content')
    <div class="container-fluid">
        <div class="col-sm-6 p-md-0  mt-2 mt-sm-0 d-flex">
            <a href="{{ route('playlist.index') }}" class="btn btn-custom">
                <i class="fa fa-arrow-left"></i> Back
            </a>
        </div>

        <div class="row">
            <div class="col-xl-12 col-xxl-12 col-lg-12 mt-4">
                <form action="{{ route('playlist.readmore.update', $playlist->id) }}" method="POST" enctype="multipart/form-data">
                    @method('put')
                    @csrf
                    <div class="card">
                        <div class="card-header bg-custom">
                            <h4 class="text-white m-0">Add Or Edit Readmore In {{ $playlist->name }}</h4>
                        </div>
                        <div class="card-body">
                            <x-input name='title' type="text" placeholder="Title" value="{{ $playlist->readmore->title ?? $playlist->name }}" />

                            <x-input name='sub_title' type="text" placeholder="Sub Title" value="{{ $playlist->readmore?->sub_title }}" />

                            <textarea class="form-control" id="editor" name="content" placeholder="Content">
                                {{ $playlist->readmore?->content }}
                            </textarea>
                            @error('content')
                                <span class="text-danger">{{ $message }}</span>
                            @enderror

                            <div class="mt-3 text-right">
                                <button class="btn btn-custom rounded-0" type="submit">Save And Updated</button>
                            </div>
                        </div>
                    </div>
                </form>
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
@endpush
