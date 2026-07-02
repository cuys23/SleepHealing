@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">Playlist Details</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">playlist details view</li>
        </ol>
    </div>
@endpush
<style>
    th,
    td {
        padding: 16px 10px !important;
    }
</style>

@section('content')

<div class="row">
    <div class="col-12 col-lg-7 m-auto">
        <div class="card rounded-8">
            <div class="card-header py-2 bg-custom">
                <h4 class="text-white">Playlist Details</h4>
            </div>
            <div class="card-body">
                <div class="d-flex flex-wrap align-items-center" style="gap: 16px">
                    <img src="{{ $playlist->thumbnail }}" class="rounded-circle"  width="150" height="150">
                    <div>
                        <label class="text-muted mb-1">Name</label>
                        <p>{{ $playlist->name }}</p>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-6 mt-3">
                        <label class="text-muted mb-1 d-block">Audio</label>
                        <audio controls src="{{ $playlist->audioFile }}"></audio>
                    </div>
                    <div class="col-lg-6 mt-3">
                        <label class="text-muted mb-1">Duration</label>
                        <p>{{ $playlist->duration }}</p>
                    </div>
                    <div class="col-12 mt-3">
                        <label class="text-muted mb-1">Description</label>
                        <p>{{ $playlist->description }}</p>
                    </div>
                </div>
            </div>
            <div class="card-footer bg-white">
                <a href="{{ route('playlist.index') }}" type="button" class="btn btn-light btn">GO Back</a>
            </div>
        </div>
    </div>
</div>

@endsection
