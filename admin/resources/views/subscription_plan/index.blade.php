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
    <div class="mb-3 d-flex justify-content-end">
        <a href="{{ route('subscriptionPlan.create') }}" class="btn btn-custom"><i class="fa fa-plus"></i> Create New</a>
    </div>
    <div class="card card-body">
        <div class="table-responsive">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th scope="col">Photo</th>
                        <th scope="col">Name</th>
                        <th scope="col">Amount</th>
                        <th scope="col">Duration</th>
                        <th scope="col">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($subscriptionPlans as $plan)
                        <tr>
                            <td class="text-center">
                                <img src="{{ $plan->thumbnail }}" alt="" width="70" height="70">
                            </td>
                            <td>{{ $plan->name }}</td>
                            <td>${{ $plan->amount }}</td>
                            <td>{{ $plan->duration }} Months</td>
                            <td>
                                <a href="{{ route('subscriptionPlan.show', $plan->id) }}"
                                    class="btn btn-primary btn-sm mb-1"><i class="fa fa-eye"></i></a>
                                @if (config('app.env') == 'local')
                                    <a href="javascript:void(0)" onclick="showAlert('You can not update the subscription plan in demo mode')"
                                        class="btn btn-info btn-sm mb-1">
                                        <i class="fa fa-edit"></i>
                                    </a>
                                    <a href="javascript:void(0)" onclick="showAlert('You can not delete the subscription plan in demo mode')"
                                        class="btn btn-danger btn-sm mb-1">
                                        <i class="fa fa-trash"></i>
                                    </a>
                                @else
                                    <a href="{{ route('subscriptionPlan.edit', $plan->id) }}"
                                        class="btn btn-info btn-sm mb-1">
                                        <i class="fa fa-edit"></i>
                                    </a>
                                    @role('root|admin')
                                        <a href="{{ route('subscriptionPlan.delete', $plan->id) }}"
                                            class="btn btn-danger btn-sm mb-1 delete-confirm">
                                            <i class="fa fa-trash"></i>
                                        </a>
                                    @else
                                        <a href="javascript:void(0)" onclick="showAlert('You can not delete the subscription plan in demo mode')"
                                            class="btn btn-danger btn-sm mb-1 delete-confirm">
                                            <i class="fa fa-trash"></i>
                                        </a>
                                    @endrole
                                @endif

                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
    <div class="d-flex justify-content-end">
        {{ $subscriptionPlans->links() }}
    </div>
@endsection
