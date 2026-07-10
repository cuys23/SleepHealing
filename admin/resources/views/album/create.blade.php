@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">Album Create</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">Create new album</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="row">
        <div class="col-lg-10 col-md-12 m-auto">
            @role('root|admin')
                <form action="{{ route('albam.store') }}" method="POST" enctype="multipart/form-data">
                    @csrf
                @endrole
                <div class="card animate__animated animate__zoomIn">
                    <div class="card-header bg-success py-2">
                        <h4 class="text-white">Create Album</h4>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-8 border-right">
                                <x-input name="name" type="text" placeholder="Name" value=""></x-input>
                                <x-select name="badge" placeholder="Select Badge" value="">
                                    @foreach (\App\Enums\Badge::cases() as $badge)
                                        <option value="{{ $badge->value }}"> {{ $badge->name }} </option>
                                    @endforeach
                                </x-select>
                                <x-select name="category" placeholder="Select Category (shown under Explore/Category browse)" value="">
                                    @foreach ($categories as $category)
                                        <option value="{{ $category->id }}"> {{ $category->name }} </option>
                                    @endforeach
                                </x-select>
                                <x-select name="shift" placeholder="Select Time of Day (shown on Home)" value="">
                                    @foreach ($shifts as $shift)
                                        <option value="{{ $shift->id }}"> {{ $shift->type }} </option>
                                    @endforeach
                                </x-select>

                                <div class="">
                                    <x-textarea name="description" placeholder="Description" value="" rows="4">
                                    </x-textarea>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="form-group">
                                    <label class="mb-1">Thumbnail</label>
                                    <input type="file" class="form-control-file" name="thumbnail"
                                        onchange="previewLogoFile(event)" />
                                    <img src="" alt="" id="logoPreview" width="140" class="mt-1">
                                </div>

                                <div class="d-flex align-items-center" style="gap: 40px">
                                    <div class="d-flex align-items-center" style="gap: 4px">
                                        <input type="checkbox" name="featured" id="featured">
                                        <label class="m-0 p-0" for="featured">Featured</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex align-items-center" style="gap: 40px">
                            <div class="d-flex align-items-center" style="gap: 4px">
                                <input type="checkbox" name="active" id="active">
                                <label class="m-0 p-0" for="active">Active</label>
                            </div>
                            <div class="d-flex align-items-center" style="gap: 4px">
                                <input type="checkbox" name="paid" id="paid">
                                <label class="m-0 p-0" for="paid">Paid</label>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer py-2 d-flex justify-content-between bg-white">
                        <a href="{{ route('albam.index') }}" type="button" class="btn btn-secondary text-white">
                            <i class="fa fa-arrow-left"></i> GO Back
                        </a>
                        <button type="submit" class="btn btn-success px-md-5">Submit</button>
                    </div>
                </div>
                @role('root|admin')
                </form>
            @endrole
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
