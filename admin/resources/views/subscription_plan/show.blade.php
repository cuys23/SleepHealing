@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">Subscription Plan</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">All subscription plans</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="header py-2 d-flex justify-content-between align-items-center">
        <h4 class="m-0">Subscription plan Details</h4>
        <a href="{{ route('subscriptionPlan.index') }}" type="button" class="btn btn-secondary text-white">GO Back</a>
    </div>
    <div class="card card-body">
        <div class="d-flex justify-content-start align-items-center" style="gap: 10px">
            <div class="profile_photo">
                <img src="{{ $subscriptionPlan->thumbnail }}" alt="" width="100">
            </div>
            <div>
                <h4 class="mb-1">{{ $subscriptionPlan->name }}</h4>
            </div>
        </div>
        <div class="row mt-3">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>Feature 1</th>
                        <th>Feature 2</th>
                        <th>Feature 3</th>
                        <th>Feature 4</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>{{ $subscriptionPlan->feature_1 }}</td>
                        <td>{{ $subscriptionPlan->feature_2 }}</td>
                        <td>{{ $subscriptionPlan->feature_3 }}</td>
                        <td>{{ $subscriptionPlan->feature_4 }}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
@endsection
