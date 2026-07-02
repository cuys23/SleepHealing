@extends('layouts.app')
@push('title')
    <div class="page-title-box">
        <h4 class="page-title">App User</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">users Details</li>
        </ol>
    </div>
@endpush
@section('content')
    <div class="row">
        <div class="col-md-12 m-auto">
            <div class="header py-2 d-flex justify-content-between align-items-center">
                <h4 class="m-0">User Details</h4>
                <a href="{{ route('user.index') }}" type="button" class="btn btn-secondary text-white">GO Back</a>
            </div>
            <div class="card card-body">
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
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Thumbnail</th>
                                <th>Amount</th>
                                <th>Duration</th>
                                <th>Description</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse ($user->subscriptions as $subscription)
                                <tr>
                                    <td>{{ $subscription->subscriptionPlan?->name }}</td>
                                    <td><img src="{{ $subscription->subscriptionPlan?->thumbnail }}" alt=""
                                            width="50"></td>
                                    <td>{{ $subscription->subscriptionPlan?->amount }}</td>
                                    <td>{{ $subscription->subscriptionPlan?->duration }}</td>
                                    <td>{{ $subscription->subscriptionPlan?->description }}</td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="5">
                                        No Subscription Plan
                                    </td>
                                </tr>
                            @endforelse

                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
@endsection
