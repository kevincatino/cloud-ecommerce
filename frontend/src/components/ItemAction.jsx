import React from 'react';

const ActionButton = ({ buttonText, buttonColor, hasInput, onButtonClick, placeholder, isGetButton}) => {

    const handleKeyDown = (event) => {
        if (event.key === 'Enter') {
          onButtonClick();
        }
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
            onKeyDown={handleKeyDown}
            />
        )}
        </div>
    );
};

export default ActionButton;