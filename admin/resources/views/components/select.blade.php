<div class="form-group">
    <label class="mb-1" for="{{ $name }}">{{ $placeholder }}</label>
    <select name="{{ $name }}" class="form-control @error($name) is-invalid @enderror" id="{{ $name }}">
        <option value="" disabled selected>Selcet One</option>
        {{ $slot }}
    </select>
    @error($name)
        <small class="text-danger">{{ $message }}</small>
    @enderror
</div>
