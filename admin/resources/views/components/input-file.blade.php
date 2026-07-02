<div class="form-group">
    <label class="mb-1" for="{{ $name }}">{{ $placeholder }}</label>
    <input name="{{$name}}" id="{{ $name }}" type="file" class="form-control-file @error($name) is-invalid @enderror">
    @error($name)
        <small class="text-danger">{{ $message }}</small>
    @enderror
</div>
