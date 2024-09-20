import React from 'react';

const ActionButton = ({ 
    buttonText, 
    buttonColor, 
    hasInput, 
    onButtonClick, 
    placeholder, 
    isGetButton,
    inputValue,
    setInputValue,
    addResponse,
    getResponse,
    deleteResponse 
}) => {

    const handleKeyDown = (event) => {
        if (event.key === 'Enter') {
          onButtonClick();
        }
      };

    const handleInputChange = (event) => {
        setInputValue(event.target.value);
    };

    return (
        <div className="flex flex-col items-center justify-start ${isGetButton ? 'border-l-2 border-r-2 border-white' : ''}" style={{ width: '33.33vw', height: '100%' }}>
        <button
            className={`bg-${buttonColor}-500 hover:bg-${buttonColor}-700 text-white font-bold py-2 px-4 rounded mt-4`}
            onClick={onButtonClick}
        >
            {buttonText}
        </button>
        {hasInput && (
            <input 
            className="mt-4 px-3 py-2 border border-gray-300 rounded-lg" 
            type="text" 
            placeholder={placeholder}
            value={inputValue}
            onKeyDown={handleKeyDown}
            onChange={handleInputChange}
            />
        )}
        {addResponse && (
            <div className="mt-4 p-4 bg-gray-800 text-white border border-gray-600 rounded-lg w-11/12">
                <p className="text-lg font-semibold mb-2">Response:</p>
                <p>ID: {addResponse.id}</p>
                <p>Title: {addResponse.title}</p>
            </div>
        )}

        {getResponse && getResponse.length > 0 && (
            <div className="mt-4 p-4 bg-gray-800 text-white border border-gray-600 rounded-lg w-11/12">
                <p className="text-lg font-semibold mb-2">Fetched Items:</p>
                <ul>
                    {getResponse.map(item => (
                        <li key={item.id} className="text-sm">ID: {item.id}, Title: {item.title}</li>
                    ))}
                </ul>
            </div>
        )}

        
        {deleteResponse && deleteResponse.success && (
            <div className="mt-4 p-4 bg-gray-800 text-white border border-gray-600 rounded-lg w-11/12">
                <p className="text-lg font-semibold mb-2">Deleted Item:</p>
                <p>ID: {deleteResponse.id}</p>
            </div>
        )}
        </div>
    );
};

export default ActionButton;