import React from 'react';
import '../css/console.css'

const DeleteButton = (props) => {
    return (<button onClick={() => props.delete(props.qkey)} className="option floatright">
                <i className="fa fa-trash" aria-hidden="true"></i>
            </button>)
};

const EditButton = (props) => {
    return (<button onClick={() => props.edit(props.text, props.tags, props.qkey)} className="option floatright">
                <i className="fa fa-pencil" aria-hidden="true"></i>
            </button>)
};

export {EditButton, DeleteButton}