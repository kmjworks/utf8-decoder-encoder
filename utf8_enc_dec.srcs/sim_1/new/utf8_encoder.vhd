library ieee;
use ieee.std_logic_1164.all;

entity utf8_encoder is

    port(
        clk : in std_logic;
        rst : in std_logic;

        -- Code point that represents a unique Unicode character
        in_codepoint : in std_logic_vector(20 downto 0)
        in_valid : in std_logic;
        in_ready : out std_logic;

        -- code point translated into 1-4 UTF 8-bytes
        out_byte : out std_logic_vector(7 downto 0);
        out_valid : out std_logic;
        out_ready : in std_logic;
    );

end utf8_encoder;

architecture rtl of utf8_encoder is
    
    -- continuation bytes
    type bytes_t is array (0 to 2) of std_logic_vector(5 downto 0);
    signal bytes : bytes_t;

    -- num of remaininig continuation bytes to send
    signal bytes_left : integer range 0 to 3;

    signal encoder_busy : std_logic;

end architecture;