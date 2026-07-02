<?php

namespace App\View\Components;

use Illuminate\View\Component;

class textarea extends Component
{
    public $name, $placeholder, $rows, $value;
    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct($name,$placeholder,$rows = '5', $value)
    {
        $this->name = $name;
        $this->placeholder = $placeholder;
        $this->rows = $rows;
        $this->value = $value;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\Contracts\View\View|\Closure|string
     */
    public function render()
    {
        return view('components.textarea');
    }
}
