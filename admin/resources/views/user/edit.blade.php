@extends('layouts.app')
@push('title')
    <div class="page-title-box">
        <h4 class="page-title">App User</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">users Edit</li>
        </ol>
    </div>
@endpush
@section('content')
    @role('admin|root')
        <form action="{{ route('user.update', $user->id) }}" method="POST" enctype="multipart/form-data">
            @csrf
        @endrole
        <div class="row">
            <div class="col-md-6 m-auto">
                <div class="card">
                    <div class="card-header py-2 bg-custom">
                        <h3 class="m-0 text-white">User Edit</h3>
                    </div>
                    <div class="card-body">
                        <div class="d-flex justify-content-start align-items-center" style="gap: 10px">
                            <div class="profile_photo">
                                <img src="{{ $user->thumbnail }}" alt="" width="100">
                            </div>
                            <div>
                                <h4 class="mb-1">{{ $user->name }}</h4>
                                <p class="text-gray p-0">{{ $user->email }}</p>
                            </div>
                        </div>

                        <div class="row mt-3">
                            <div class="col-12">
                                <x-input name="name" type="text" placeholder="Name" value="{{ $user->name }}">
                                </x-input>
                            </div>
                            <div class="col-lg-6">
                                <x-input-file name="profile_photo" placeholder="Profile Photo"></x-input-file>
                            </div>
                            <div class="col-lg-6">
                                <x-input name="email" type="text" placeholder="Email" value="{{ $user->email }}">
                                </x-input>
                            </div>
                            <input type="hidden" name="id" value="{{ $user->id }}">
                            {{-- for dev mode only --}}
                            <div class="col-lg-12">
                                <x-select name="subscription" placeholder="Select Subscription">
                                    <option value="0">No Subscription</option>
                                    @forelse ($subscriptions as $item)
                                        <option value="{{ $item->id }}"
                                            {{ $user->subscriptions->first()?->subscription_plan_id == $item->id ? 'selected' : '' }}>{{ $item->name }}
                                        </option>
                                    @empty
                                    @endforelse
                                </x-select>
                            </div>
                            {{-- for dev mode only --}}
                        </div>
                    </div>
                    <div class="card-footer d-flex justify-content-between bg-white">
                        <a href="{{ route('user.index') }}" type="button" class="btn btn-secondary text-white">GO Back</a>
                        <button type="submit" class="btn btn-custom">Save And Update</button>
                    </div>
                </div>
            </div>
        </div>
        @role('admin|root')
        </form>
    @endrole
@endsection
